import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import '../../data/models/terms_section.dart';
import '../../data/services/terms_service.dart';
import 'widgets/terms_header.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final TermsService _termsService = TermsService();
  late List<TermsSection> _sections;
  late List<TermsSection> _filteredSections;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Use ValueNotifier for progress to avoid full-screen rebuilds on scroll
  final ValueNotifier<double> _readingProgress = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    _sections = _termsService.getTermsSections();
    _filteredSections = _sections;
    _scrollController.addListener(_updateProgress);
  }

  void _updateProgress() {
    if (_scrollController.hasClients) {
      final progress = _scrollController.offset / (_scrollController.position.maxScrollExtent.clamp(1.0, double.infinity));
      _readingProgress.value = progress.clamp(0.0, 1.0);
    }
  }

  void _filterSections(String query) {
    setState(() {
      _filteredSections = _sections
          .where((section) =>
              section.title.toLowerCase().contains(query.toLowerCase()) ||
              section.content.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _readingProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: ValueListenableBuilder<double>(
            valueListenable: _readingProgress,
            builder: (context, progress, child) {
              return LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              );
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          // Use CustomScrollView for lazy loading and smooth performance
          CustomScrollView(
            controller: _scrollController,
            physics: Platform.isIOS ? const BouncingScrollPhysics() : const ClampingScrollPhysics(),
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                sliver: SliverToBoxAdapter(child: TermsHeader()),
              ),
              
              // Search Bar
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterSections,
                      decoration: InputDecoration(
                        hintText: 'Search Terms...',
                        hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
              ),

              // Lazy-loaded list of sections
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _TermsCard(
                          key: ValueKey(_filteredSections[index].title),
                          section: _filteredSections[index],
                        ),
                      );
                    },
                    childCount: _filteredSections.length,
                  ),
                ),
              ),
            ],
          ),

          // Accept Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: _StickyAcceptButton(
                  onPressed: () async {
                    await _termsService.acceptTerms();
                    if (mounted) Navigator.pop(context, true);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsCard extends StatefulWidget {
  final TermsSection section;
  const _TermsCard({super.key, required this.section});

  @override
  State<_TermsCard> createState() => _TermsCardState();
}

class _TermsCardState extends State<_TermsCard> {
  // Use a simpler boolean toggle for expansion
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: AppColors.primaryBlue.withValues(alpha: 0.05),
        ),
        child: ExpansionTile(
          key: PageStorageKey(widget.section.title),
          onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
          title: Text(
            widget.section.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _isExpanded ? 0.5 : 0,
            child: const Icon(Icons.expand_more, color: AppColors.primaryBlue),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 12),
                  Text(
                    widget.section.content,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyAcceptButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _StickyAcceptButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryBlue, Color(0xFF1E63FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(
          'I Have Read & Agree',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
