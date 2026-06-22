import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// أنماط النصوص — مأخوذة من أكواد CSS في ملف HTML المرجعي
/// كل TextStyle له تعليق بالكلاس اللي أخدناه منه
abstract final class AppTextStyles {
  // ── Logo ──────────────────────────────────────────────────
  /// `.logo-text` — 16px, w800, gradient (نستخدم w800 هنا)
  static TextStyle logoText(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w800);

  /// `.login-title` — 28px, w900, gradient text
  static TextStyle loginTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 28, fontWeight: FontWeight.w900);

  // ── Balance ───────────────────────────────────────────────
  /// `.balance-amount` — 32px, w900, accent color
  static TextStyle balanceAmount(BuildContext context) =>
      _base(context).copyWith(fontSize: 32, fontWeight: FontWeight.w900);

  /// `.balance-label` — 13px, text-secondary
  static TextStyle balanceLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w400);

  // ── Stats ─────────────────────────────────────────────────
  /// `.stat-value` — 16px, w800
  static TextStyle statValue(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w800);

  /// `.stat-label` — 10px, text-secondary
  static TextStyle statLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 10, fontWeight: FontWeight.w400);

  // ── Sections ──────────────────────────────────────────────
  /// `.section-title` — 14px, w700
  static TextStyle sectionTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w700);

  /// `.section-title a` — 12px, accent, w500
  static TextStyle sectionLink(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w500);

  // ── Cards ─────────────────────────────────────────────────
  /// `.card-title` — 14px, w700
  static TextStyle cardTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w700);

  /// `.card-sub` — 11px, text-secondary
  static TextStyle cardSub(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w400);

  /// `.card-amount` — 14px, w800, accent
  static TextStyle cardAmount(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800);

  /// `.empty-title` — 16px, w700
  static TextStyle emptyTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w700);

  /// `.empty-text` — 13px, text-secondary
  static TextStyle emptyText(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w400);

  // ── Modal ─────────────────────────────────────────────────
  /// `.modal-title` — 18px, w800
  static TextStyle modalTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 18, fontWeight: FontWeight.w800);

  // ── Forms ─────────────────────────────────────────────────
  /// `.form-label` — 12px, w600, text-secondary
  static TextStyle formLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w600);

  /// `.form-input` — 14px, regular
  static TextStyle formInput(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w400);

  /// `.form-input::placeholder` — 14px, text-muted
  static TextStyle formPlaceholder(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w400);

  // ── Buttons ───────────────────────────────────────────────
  /// `.btn` — 14px, w700
  static TextStyle button(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w700);

  /// `.btn-primary` — same as .btn
  static TextStyle buttonPrimary(BuildContext context) => button(context);

  /// `.login-btn` — 16px, w700
  static TextStyle loginButton(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w700);

  /// `.login-input` — 16px, regular
  static TextStyle loginInput(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w400);

  // ── Tabs & Chips ──────────────────────────────────────────
  /// `.tab` — 12px, w600
  static TextStyle tab(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w600);

  /// `.workshop-btn` — 11px, w700
  static TextStyle workshopButton(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w700);

  /// `.category-chip` — 10px, w700
  static TextStyle categoryChip(BuildContext context) =>
      _base(context).copyWith(fontSize: 10, fontWeight: FontWeight.w700);

  /// `.period-btn` — 11px, w600
  static TextStyle periodButton(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w600);

  /// `.nav-label` — 8px, w600
  static TextStyle navLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 8, fontWeight: FontWeight.w600);

  // ── Badge ─────────────────────────────────────────────────
  /// `.badge` — 10px, w600
  static TextStyle badge(BuildContext context) =>
      _base(context).copyWith(fontSize: 10, fontWeight: FontWeight.w600);

  // ── Search ────────────────────────────────────────────────
  /// `.search-input` — 13px, regular
  static TextStyle searchInput(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w400);

  // ── Details ───────────────────────────────────────────────
  /// `.detail-section-title` — 13px, w700
  static TextStyle detailSectionTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w700);

  /// `.detail-label` — 12px, text-secondary
  static TextStyle detailLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w400);

  /// `.detail-value` — 13px, w600
  static TextStyle detailValue(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600);

  /// `.detail-tab` — 13px, w700
  static TextStyle detailTab(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w700);

  // ── Summary ───────────────────────────────────────────────
  /// `.summary-label` — 12px, text-secondary
  static TextStyle summaryLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w400);

  /// `.summary-value` — 13px, w700
  static TextStyle summaryValue(BuildContext context) =>
      _base(context).copyWith(fontSize: 13, fontWeight: FontWeight.w700);

  /// `.summary-total` — 16px, accent
  static TextStyle summaryTotal(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w700);

  // ── Treasury ──────────────────────────────────────────────
  /// `.treasury-card .t-amount` — 14px, w800
  static TextStyle treasuryAmount(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800);

  /// `.finance-mini-card .fvalue` — 16px, w800
  static TextStyle financeMiniValue(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w800);

  /// `.finance-mini-card .flabel` — 10px, text-secondary
  static TextStyle financeMiniLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 10, fontWeight: FontWeight.w400);

  /// `.finance-card-large .fvalue` — 26px, w900
  static TextStyle financeLargeValue(BuildContext context) =>
      _base(context).copyWith(fontSize: 26, fontWeight: FontWeight.w900);

  /// `.finance-card-large .flabel` — 11px, w600, text-secondary
  static TextStyle financeLargeLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w600);

  // ── Transactions ──────────────────────────────────────────
  /// `.tx-amount-main` — 16px, w800
  static TextStyle txAmountMain(BuildContext context) =>
      _base(context).copyWith(fontSize: 16, fontWeight: FontWeight.w800);

  /// `.tx-date-label` — 11px, text-secondary
  static TextStyle txDateLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w400);

  /// `.tx-before-label` — 11px, text-muted
  static TextStyle txBeforeLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w400);

  /// `.tx-note-label` — 11px, text-secondary
  static TextStyle txNoteLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w400);

  /// `.tx-tag-amount` — 20px, w900
  static TextStyle txTagAmount(BuildContext context) =>
      _base(context).copyWith(fontSize: 20, fontWeight: FontWeight.w900);

  /// `.tx-tag-label` — 10px, w700
  static TextStyle txTagLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 10, fontWeight: FontWeight.w700);

  // ── Reports ───────────────────────────────────────────────
  /// `.report-card .rc-label` — 11px, text-secondary
  static TextStyle reportCardLabel(BuildContext context) =>
      _base(context).copyWith(fontSize: 11, fontWeight: FontWeight.w400);

  /// `.report-card .rc-value` — 20px, w800
  static TextStyle reportCardValue(BuildContext context) =>
      _base(context).copyWith(fontSize: 20, fontWeight: FontWeight.w800);

  // ── PL Report ─────────────────────────────────────────────
  /// `.pl-section-title` — 14px, w800
  static TextStyle plSectionTitle(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800);

  /// `.pl-row` — 12px
  static TextStyle plRow(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w400);

  /// `.pl-total-row` — 14px, w800
  static TextStyle plTotalRow(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800);

  // ── Person Detail ─────────────────────────────────────────
  /// `.person-bottom-bar .action-btn` — 14px, w800
  static TextStyle personActionBtn(BuildContext context) =>
      _base(context).copyWith(fontSize: 14, fontWeight: FontWeight.w800);

  /// `.action-btn` — 15px, w800
  static TextStyle actionBtn(BuildContext context) =>
      _base(context).copyWith(fontSize: 15, fontWeight: FontWeight.w800);

  /// `.back-btn` — 12px, w600
  static TextStyle backBtn(BuildContext context) =>
      _base(context).copyWith(fontSize: 12, fontWeight: FontWeight.w600);

  // ── Helper ────────────────────────────────────────────────
  static TextStyle _base(BuildContext context) {
    return GoogleFonts.tajawal(
      color: Theme.of(context).colorScheme.onSurface,
    );
  }
}
