class AdminStats {
  final int totalUsers;
  final int totalBusinesses;
  final int totalTransactions;
  final double totalRevenue;
  final List<double> weeklyRevenue;
  final int blockedUsers;

  AdminStats({
    required this.totalUsers,
    required this.totalBusinesses,
    required this.totalTransactions,
    required this.totalRevenue,
    required this.weeklyRevenue,
    required this.blockedUsers,
  });

  factory AdminStats.empty() {
    return AdminStats(
      totalUsers: 0,
      totalBusinesses: 0,
      totalTransactions: 0,
      totalRevenue: 0,
      weeklyRevenue: List.filled(7, 0.0),
      blockedUsers: 0,
    );
  }
}
