# Package Rules

Before adding any package:

- Verify it is actively maintained.
- Prefer official Flutter packages when available.
- Ensure it supports Android and iOS.
- Avoid deprecated packages.
- Minimize unnecessary dependencies.

---

# AI Behavior Rules

Before generating any code:

1. Understand the existing project structure.
2. Check whether similar functionality already exists.
3. Do not create duplicate code.
4. If a feature depends on another feature, implement the dependency first.
5. Keep the project consistent with the overall architecture.
6. When uncertain, choose the solution that is most scalable and maintainable.
7. Generate complete implementations rather than partial examples unless explicitly requested.
8. Always keep Android and iOS compatibility in mind.
9. Ensure all code integrates cleanly with the existing project.

# DigiKhata Pro AI Development Guide

## Project Name

DigiKhata Pro

## Project Type

Production-ready Flutter bookkeeping application inspired by DigiKhata.

## Project Objective

Build a complete bookkeeping application using Flutter and Supabase that replicates the workflow, business logic, and functionality of the DigiKhata application while maintaining a completely original UI and UX.

The application must use a modern Blue Theme, Clean Architecture, Riverpod, Material 3, and production-ready coding standards.

The goal is to create a scalable, secure, responsive, and cross-platform application that works flawlessly on both Android and iOS.

---

# Core Features

The application must include:

## Authentication

- Splash Screen
- User Registration
- Login
- Forgot Password
- Secure Authentication
- Biometric Login
- Session Management

---

## Business Management

- Create Business
- Edit Business
- Delete Business
- Multiple Businesses
- Business Settings
- Switch Business

---

## Customer Management

- Add Customer
- Edit Customer
- Delete Customer
- Search Customer
- Customer Ledger
- Due Balance
- Customer Notes

---

## Transactions

- Credit Entry
- Debit Entry
- Cash In
- Cash Out
- Transaction History
- Edit Transaction
- Delete Transaction
- Search Transactions
- Transaction Filters

---

## Reports

- Daily Report
- Weekly Report
- Monthly Report
- Yearly Report
- Custom Date Reports
- PDF Export
- Excel Export

---

## Analytics

- Dashboard Statistics
- Revenue Charts
- Credit/Debit Charts
- Customer Statistics
- Business Insights

---

## Notifications

- Push Notifications
- Announcements
- Due Reminders
- Promotional Messages
- System Notifications

---

## User Profile

- Profile Management
- Change Password
- Language
- Theme
- Security
- Backup & Restore

---

## Additional Features

- QR Code Sharing
- Offline Mode
- Automatic Sync
- Automatic Backup
- Dark Mode
- Multi-language Support
- Responsive Layout
- Error Handling
- Loading States

---

# Super Admin Panel

The project must include a dedicated Super Admin Panel.

Features:

- Dashboard
- Analytics
- Manage Users
- Manage Businesses
- View Transactions
- Manage Banners
- Manage Announcements
- Send Push Notifications
- Application Settings
- Reports
- Statistics
- Block/Unblock Users

---

# Branding

Always include:

- Zenvyro Labs Logo
- Powered by Zenvyro Labs

Branding must remain visible on:

- Splash Screen
- Dashboard
- Login Screen (Footer)

Do not remove or modify the branding.

---

# Technology Stack

Frontend

- Flutter

Backend

- Supabase

State Management

- Riverpod

Architecture

- Clean Architecture

Routing

- GoRouter

Local Storage

- Drift (Preferred)

Notifications

- Firebase Cloud Messaging

Charts

- fl_chart

PDF

- pdf
- printing

Excel

- excel

QR

- qr_flutter

Localization

- easy_localization

Dependency Injection

- get_it

---

# Final Goal

Every generated screen, widget, feature, service, provider, repository, and database implementation should contribute toward building the complete DigiKhata Pro application.

The AI must always consider the project as a production-ready fintech bookkeeping application and ensure that every generated code aligns with the overall architecture, design system, coding standards, and project objectives.

# Code Generation Rules

Every generated code must:

- Compile without errors.
- Be null-safe.
- Follow Clean Architecture.
- Follow Riverpod.
- Use reusable widgets.
- Use centralized theme classes.
- Handle loading, success, empty, and error states.
- Be optimized for performance.
- Be production-ready.

---

# Design System

The application must follow a consistent fintech-inspired design system.

Never introduce arbitrary colors, fonts, spacing, or component styles.

Every new screen must use the design system defined below.

---

# Color Palette

| Role | Color | Hex | Usage |
|------|------|------|------|
| Primary Dark | Deep Navy | #0A2540 | Splash background start, app bar, dark surfaces |
| Primary | Electric Blue | #2979FF | Primary buttons, active states, links, gradient end |
| Primary Light | Sky Blue | #5B9CFF | Hover states, chips, secondary actions |
| Accent | Amber Gold | #FFB300 | Loading indicators, highlights, positive totals |
| Success | Green | #00C48C | Credit entries, paid status, positive balance |
| Danger | Red | #FF4C61 | Debit entries, delete actions, due balances |
| Background Light | Off White | #F5F7FA | Light mode screen background |
| Background Dark | Charcoal Navy | #0F1B2D | Dark mode screen background |
| Surface Light | White | #FFFFFF | Cards, dialogs, bottom sheets |
| Surface Dark | Slate | #16233A | Cards, dialogs, bottom sheets |
| Text Primary | Almost Black | #1A1D29 | Headings and body text |
| Text Secondary | Gray | #6B7280 | Subtitles, hints, timestamps |
| Divider | Light Gray | #E5E9F0 | Borders and separators |

---

# Gradient

Use the following gradient throughout the application where appropriate.

Splash Screen

App Headers

Authentication Screens

Dashboard Header

Charts

Gradient

Start Color

#0A2540

End Color

#2979FF

Angle

135°

Never use random gradients.

---

# Typography

Use Google Fonts.

Headings

Font

Poppins

Weight

700

Size

28

Screen Titles

Font

Poppins

Weight

600

Size

20

Card Titles

Font

Inter

Weight

500

Size

16

Body Text

Font

Inter

Weight

400

Size

14

Captions

Font

Inter

Weight

400

Size

12

Amounts

Font

Roboto Mono (Preferred)

Fallback

Inter

Weight

700

Size

24

Rules

Use Poppins only for:

- Branding
- App Title
- Major Headings

Use Inter for:

- Paragraphs
- Labels
- Forms
- Lists
- Buttons

Use Roboto Mono only for displaying monetary values.

---

# Button Style

Primary Button

- Background: #2979FF
- Text: White
- Border Radius: 12px
- Subtle Elevation
- Full Width when appropriate

Secondary Button

- Transparent Background
- Border: #2979FF
- Text: #2979FF
- Border Radius: 12px

Danger Button

- Background: #FF4C61
- White Text
- Border Radius: 12px

Never use square buttons.

---

# Card Style

Light Mode

Background

#FFFFFF

Dark Mode

Background

#16233A

Border Radius

16px

Padding

16px

Shadow

0px 4px 12px rgba(10,37,64,0.08)

Cards should have consistent spacing and modern fintech styling.

---

# Input Fields

Use Material 3 text fields.

Requirements

- Border Radius: 10px
- Filled Background: #F5F7FA
- Focus Border: #2979FF
- Floating Labels
- Proper Validation
- Error Messages
- Prefix/Suffix Icons where appropriate

Never use outdated Material 2 input styles.

---

# Transaction List Style

Credit Entry

- Green Icon Background
- Green Amount (#00C48C)
- Plus Indicator

Debit Entry

- Red Icon Background
- Red Amount (#FF4C61)
- Minus Indicator

Always support swipe actions.

Swipe Left

Delete

Swipe Right

Edit

Use smooth animations.

---

# Bottom Navigation

Preferred Tabs

- Dashboard
- Customers
- Ledger
- Reports
- Profile

Active State

Color

#2979FF

Inactive State

#9CA3AF

Use Material 3 Navigation Bar.

Never use outdated BottomNavigationBar unless specifically required.

---

# Charts

Use fl_chart.

Line Charts

Gradient Fill

#2979FF → Transparent

Pie Charts

Allowed Colors

- #2979FF
- #5B9CFF
- #FFB300
- #00C48C
- #FF4C61

Bar Charts

Use Blue Theme.

Avoid random color combinations.

---

# Dark Mode

Always support Light and Dark themes.

Color Mapping

Background

Light

#F5F7FA

Dark

#0F1B2D

Cards

Light

#FFFFFF

Dark

#16233A

Primary

Light

#2979FF

Dark

#5B9CFF

Primary Text

Light

#1A1D29

Dark

#E8EAF0

Secondary Text

Light

#6B7280

Dark

#A7B1C2

Never hardcode colors.

Always reference centralized AppColors and AppTheme classes.

---

# Theme Rules

Always create:

- app_colors.dart
- app_theme.dart
- app_text_styles.dart
- app_spacing.dart
- app_radius.dart
- app_shadows.dart

Never hardcode colors, fonts, spacing, radius, or shadows inside widgets.

All UI components must use the centralized design system.

---

# UI Consistency Rules

Every screen should:

- Follow the same spacing system.
- Follow the same typography.
- Follow the same color palette.
- Follow the same component styling.
- Use responsive layouts.
- Support Android and iOS.
- Support Light and Dark themes.
- Be production-ready.
- Feel like part of the same design system.

Always maintain a clean, modern, premium fintech appearance throughout the application.