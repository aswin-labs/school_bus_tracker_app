import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/student_model.dart';
import 'package:school_bus_tracker/features/live_tracking/data/models/transport_invoice_model.dart';
import 'package:school_bus_tracker/features/live_tracking/presentation/provider/student_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentDetailsDialog extends StatefulWidget {
  final int studentId;
  final StudentModel? initialStudent;

  const StudentDetailsDialog({
    super.key,
    required this.studentId,
    this.initialStudent,
  });

  static void show(
    BuildContext context,
    int studentId, {
    StudentModel? initialStudent,
  }) {
    showDialog(
      context: context,
      builder: (_) => StudentDetailsDialog(
        studentId: studentId,
        initialStudent: initialStudent,
      ),
    );
  }

  @override
  State<StudentDetailsDialog> createState() => _StudentDetailsDialogState();
}

class _StudentDetailsDialogState extends State<StudentDetailsDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = context.read<StudentProvider>();
        provider.fetchStudentDetailsById(widget.studentId);
        provider.fetchTransportInvoicesByStudentId(widget.studentId);
      }
    });
  }

  String _formatAmount(String amountStr) {
    final val = double.tryParse(amountStr);
    if (val == null) return amountStr;
    return '₹${val.toStringAsFixed(2)}';
  }

  Future<void> _makePhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showEnlargedImage(BuildContext context, String imageUrl, String studentName) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(maxHeight: 420),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => const Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            color: Colors.white60,
                            size: 48,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Unable to load image',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              studentName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final year = dt.year;
      return '$day $month $year';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        constraints: BoxConstraints(maxHeight: height * 0.88, maxWidth: 460),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STUDENT PROFILE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Detailed Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer<StudentProvider>(
                    builder: (context, provider, _) {
                      final student = provider.studentDetails ?? widget.initialStudent;
                      final status = student?.status ?? 'active';
                      final isActive = status.toLowerCase() == 'active';

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.greenAccent.withAlpha(50)
                              : Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive
                                ? Colors.greenAccent.withAlpha(120)
                                : Colors.white.withAlpha(60),
                          ),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isActive ? Colors.white : Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── BODY CONTENT ────────────────────────────────────
            Expanded(
              child: Consumer<StudentProvider>(
                builder: (context, provider, _) {
                  final student = provider.studentDetails ?? widget.initialStudent;
                  final isLoading = provider.isLoadingDetails;

                  if (isLoading && student == null) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 14),
                          Text(
                            'Loading student details...',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (student == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Failed to Load Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Could not fetch student information at this time.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<StudentProvider>()
                                    .fetchStudentDetailsById(widget.studentId);
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final user = student.user;
                  final guardian = user?.guardian;
                  final classInfo = student.classGrade;

                  final initials = student.fullName
                      .trim()
                      .split(' ')
                      .take(2)
                      .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                      .join();

                  final activeInvoices =
                      provider.invoices.where((inv) => !inv.trash).toList();
                  final hasPendingInvoices =
                      activeInvoices.any((inv) => inv.isOutstanding);

                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── HERO PROFILE CARD ─────────────────
                            _buildHeroCard(
                              student,
                              initials,
                              hasPendingInvoices: hasPendingInvoices,
                            ),

                            const SizedBox(height: 16),

                            // ── TRANSPORT INVOICES & PAYMENTS ─────
                            _buildInvoicesSection(provider),

                            const SizedBox(height: 16),

                            // ── ACADEMIC & PERSONAL INFO ──────────
                            _buildSectionCard(
                              title: 'ACADEMIC & PERSONAL DETAILS',
                              icon: Icons.badge_outlined,
                              children: [
                                _buildDetailRow(
                                  icon: Icons.school_outlined,
                                  label: 'Class & Division',
                                  value: classInfo?.classname ?? '—',
                                ),
                                _buildDivider(),
                                _buildDetailRow(
                                  icon: Icons.numbers_rounded,
                                  label: 'Roll Number',
                                  value: student.rollNumber != null
                                      ? '#${student.rollNumber}'
                                      : '—',
                                ),
                                _buildDivider(),
                                _buildDetailRow(
                                  icon: Icons.app_registration_rounded,
                                  label: 'Registration No',
                                  value: student.regNo ?? '—',
                                ),
                                _buildDivider(),
                                _buildDetailRow(
                                  icon: Icons.transgender_rounded,
                                  label: 'Gender',
                                  value: student.gender != null
                                      ? student.gender![0].toUpperCase() +
                                          student.gender!.substring(1)
                                      : '—',
                                ),
                                _buildDivider(),
                                _buildDetailRow(
                                  icon: Icons.cake_outlined,
                                  label: 'Date of Birth',
                                  value: _formatDate(student.dateOfBirth),
                                ),
                                if (student.admissionDate != null) ...[
                                  _buildDivider(),
                                  _buildDetailRow(
                                    icon: Icons.event_available_outlined,
                                    label: 'Admission Date',
                                    value: _formatDate(student.admissionDate),
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ── PRIMARY GUARDIAN (User) ────────────
                            _buildPrimaryGuardianCard(user, guardian),

                            // ── SECONDARY GUARDIAN ─────────────────
                            if (guardian != null &&
                                (guardian.guardian2Name != null &&
                                    guardian.guardian2Name!.isNotEmpty)) ...[
                              const SizedBox(height: 16),
                              _buildSecondaryGuardianCard(guardian),
                            ],

                            // ── PARENTS DETAILS (if available) ────
                            if (guardian != null &&
                                ((guardian.fatherName != null &&
                                        guardian.fatherName!.isNotEmpty) ||
                                    (guardian.motherName != null &&
                                        guardian.motherName!.isNotEmpty))) ...[
                              const SizedBox(height: 16),
                              _buildParentsCard(guardian),
                            ],

                            // ── RESIDENTIAL ADDRESS ────────────────
                            const SizedBox(height: 16),
                            _buildAddressCard(student, guardian),
                          ],
                        ),
                      ),
                      if (isLoading)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            color: AppColors.primary,
                            minHeight: 3,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // ── FOOTER ──────────────────────────────────────────
            Consumer<StudentProvider>(
              builder: (context, provider, _) {
                final student = provider.studentDetails ?? widget.initialStudent;
                final phone = student?.user?.phone;
                final hasPhone = phone != null && phone.trim().isNotEmpty;

                return Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(
                      top: BorderSide(color: AppColors.divider, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (hasPhone) ...[
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _makePhoneCall(phone),
                            icon: const Icon(Icons.call_rounded, size: 18),
                            label: const Text(
                              'Call Primary Guardian',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(
                            color: AppColors.border,
                            width: 1.2,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── HERO CARD ────────────────────────────────────────────────
  Widget _buildHeroCard(
    StudentModel student,
    String initials, {
    bool hasPendingInvoices = false,
  }) {
    final hasImage = student.image != null && student.image!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        children: [
          // Student Image or Initials Avatar
          GestureDetector(
            onTap: hasImage
                ? () => _showEnlargedImage(
                      context,
                      student.image!,
                      student.fullName,
                    )
                : null,
            child: Stack(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(40),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: hasImage
                        ? Image.network(
                            student.image!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                initials.isEmpty ? '?' : initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initials.isEmpty ? '?' : initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ),
                if (hasImage)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                      child: const Icon(
                        Icons.fullscreen_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (student.classGrade?.classname != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          student.classGrade!.classname!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    if (student.regNo != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(30),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          'Reg: ${student.regNo}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    if (student.rollNumber != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(30),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          'Roll: ${student.rollNumber}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    if (hasPendingInvoices)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withAlpha(140),
                            width: 0.9,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 11.5,
                              color: Color(0xFFD97706),
                            ),
                            SizedBox(width: 3.5),
                            Text(
                              'Fee Pending',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TRANSPORT INVOICES SECTION ──────────────────────────────
  Widget _buildInvoicesSection(StudentProvider provider) {
    final isLoading = provider.isLoadingInvoices;
    final invoices = provider.invoices;

    // Filter out trash
    final activeInvoices = invoices.where((inv) => !inv.trash).toList();

    // Calculate totals
    final pendingInvoices =
        activeInvoices.where((inv) => inv.isOutstanding).toList();
    final totalPendingAmount = pendingInvoices.fold<double>(
      0.0,
      (sum, inv) => sum + inv.amountValue,
    );
    final overdueCount = pendingInvoices.where((inv) => inv.isOverdue).length;

    // Sort: pending first, then by id descending
    final sortedInvoices = List<TransportInvoiceModel>.from(activeInvoices)
      ..sort((a, b) {
        if (a.isOutstanding && !b.isOutstanding) return -1;
        if (!a.isOutstanding && b.isOutstanding) return 1;
        return b.id.compareTo(a.id);
      });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: pendingInvoices.isNotEmpty
              ? const Color(0xFFF59E0B).withAlpha(110)
              : AppColors.border,
          width: pendingInvoices.isNotEmpty ? 1.4 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: pendingInvoices.isNotEmpty
                      ? const Color(0xFFF59E0B).withAlpha(30)
                      : AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  pendingInvoices.isNotEmpty
                      ? Icons.receipt_long_rounded
                      : Icons.receipt_rounded,
                  size: 15,
                  color: pendingInvoices.isNotEmpty
                      ? const Color(0xFFD97706)
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'TRANSPORT INVOICES',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              if (pendingInvoices.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withAlpha(120),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 12,
                        color: Color(0xFFD97706),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pendingInvoices.length} PENDING',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD97706),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                )
              else if (!isLoading && activeInvoices.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.success.withAlpha(90),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'ALL PAID',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.successDark,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Loading state
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Checking payment records...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (activeInvoices.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No transport invoices found for this student.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Total Pending Summary Banner (if there are pending payments)
            if (pendingInvoices.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFEF3C7),
                      Color(0xFFFFFBEB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withAlpha(140),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.payments_outlined,
                        size: 20,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Outstanding Balance',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatAmount(totalPendingAmount.toStringAsFixed(2)),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (overdueCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.error.withAlpha(90),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 13,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$overdueCount Overdue',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

            // Invoices list
            ...sortedInvoices.map((inv) => _buildInvoiceItemCard(inv)),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceItemCard(TransportInvoiceModel invoice) {
    // Status visual details
    Color statusBg;
    Color statusText;
    Color statusBorder;
    String statusLabel;
    IconData statusIcon;

    if (invoice.isPaid) {
      statusBg = AppColors.success.withAlpha(20);
      statusText = AppColors.successDark;
      statusBorder = AppColors.success.withAlpha(60);
      statusLabel = 'PAID';
      statusIcon = Icons.check_circle_rounded;
    } else if (invoice.isWaitingApproval) {
      statusBg = const Color(0xFFF97316).withAlpha(20);
      statusText = const Color(0xFFEA580C);
      statusBorder = const Color(0xFFF97316).withAlpha(60);
      statusLabel = 'WAITING APPROVAL';
      statusIcon = Icons.hourglass_top_rounded;
    } else if (invoice.isPartiallyPaid) {
      statusBg = const Color(0xFF3B82F6).withAlpha(20);
      statusText = const Color(0xFF2563EB);
      statusBorder = const Color(0xFF3B82F6).withAlpha(60);
      statusLabel = 'PARTIALLY PAID';
      statusIcon = Icons.pie_chart_outline_rounded;
    } else {
      // Pending
      statusBg = const Color(0xFFF59E0B).withAlpha(20);
      statusText = const Color(0xFFD97706);
      statusBorder = const Color(0xFFF59E0B).withAlpha(60);
      statusLabel = 'PENDING';
      statusIcon = Icons.pending_outlined;
    }

    final isOverdue = invoice.isOverdue;
    final termText = invoice.term != null && invoice.term!.isNotEmpty
        ? invoice.term!
        : 'Invoice #${invoice.id}';
    final stopName = invoice.stop?.stopName;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverdue
              ? AppColors.error.withAlpha(70)
              : invoice.isOutstanding
                  ? const Color(0xFFF59E0B).withAlpha(50)
                  : AppColors.border,
          width: isOverdue ? 1.3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Term, Stop Name, Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 11,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      termText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (stopName != null && stopName.isNotEmpty) ...[
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          stopName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                const Spacer(),
              const SizedBox(width: 6),
              // Status Badge
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusBorder, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 10.5, color: statusText),
                      const SizedBox(width: 3.5),
                      Flexible(
                        child: Text(
                          statusLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: statusText,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Bottom Row: Amount and Due Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _formatAmount(invoice.amount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: invoice.isOutstanding
                          ? const Color(0xFFB45309)
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (invoice.dueDate != null && invoice.dueDate!.isNotEmpty) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Due: ${_formatDate(invoice.dueDate)}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                            color: isOverdue ? AppColors.error : AppColors.textSecondary,
                          ),
                        ),
                        if (isOverdue) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'OVERDUE',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: 1),
                  Text(
                    'Invoice #${invoice.id}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── PRIMARY GUARDIAN CARD ────────────────────────────────────
  Widget _buildPrimaryGuardianCard(User? user, GuardianModel? guardian) {
    final name = user?.name ?? 'Not Available';
    final phone = user?.phone;
    final relation = guardian?.guardianRelation;
    final job = guardian?.guardianJob;
    final email = user?.email;
    final dp = user?.dp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withAlpha(45),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PRIMARY GUARDIAN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (relation != null && relation.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      relation.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Guardian DP / Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: (dp != null && dp.isNotEmpty)
                      ? Image.network(
                          dp,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (job != null && job.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.work_outline_rounded,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              job,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (phone != null && phone.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _makePhoneCall(phone),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success.withAlpha(60),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.call_rounded,
                          size: 15,
                          color: AppColors.successDark,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.successDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (phone != null && phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoChip(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: phone,
              onTap: () => _makePhoneCall(phone),
            ),
          ],
          if (email != null && email.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoChip(
              icon: Icons.email_outlined,
              label: 'Email',
              value: email,
            ),
          ],
        ],
      ),
    );
  }

  // ── SECONDARY GUARDIAN CARD ──────────────────────────────────
  Widget _buildSecondaryGuardianCard(GuardianModel guardian) {
    final name = guardian.guardian2Name!;
    final phone = guardian.guardian2Contact;
    final relation = guardian.guardian2Relation;
    final job = guardian.guardian2Job;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.dropColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.people_alt_outlined,
                  size: 15,
                  color: AppColors.dropColor,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'SECONDARY GUARDIAN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (relation != null && relation.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dropColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.dropColor.withAlpha(60),
                      ),
                    ),
                    child: Text(
                      relation.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dropColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (job != null && job.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        job,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (phone != null && phone.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _makePhoneCall(phone),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success.withAlpha(60),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.call_rounded,
                          size: 15,
                          color: AppColors.successDark,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Call',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.successDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (phone != null && phone.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildInfoChip(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: phone,
              onTap: () => _makePhoneCall(phone),
            ),
          ],
        ],
      ),
    );
  }

  // ── PARENTS CARD ─────────────────────────────────────────────
  Widget _buildParentsCard(GuardianModel guardian) {
    return _buildSectionCard(
      title: 'PARENTS INFORMATION',
      icon: Icons.family_restroom_rounded,
      children: [
        if (guardian.fatherName != null && guardian.fatherName!.isNotEmpty) ...[
          _buildDetailRow(
            icon: Icons.person_rounded,
            label: "Father's Name",
            value: guardian.fatherName!,
          ),
        ],
        if (guardian.fatherName != null &&
            guardian.fatherName!.isNotEmpty &&
            guardian.motherName != null &&
            guardian.motherName!.isNotEmpty) ...[
          _buildDivider(),
        ],
        if (guardian.motherName != null && guardian.motherName!.isNotEmpty) ...[
          _buildDetailRow(
            icon: Icons.person_outline_rounded,
            label: "Mother's Name",
            value: guardian.motherName!,
          ),
        ],
      ],
    );
  }

  // ── RESIDENTIAL ADDRESS CARD ─────────────────────────────────
  Widget _buildAddressCard(StudentModel student, GuardianModel? guardian) {
    final parts = <String>[];

    if (student.address != null && student.address!.trim().isNotEmpty) {
      parts.add(student.address!.trim());
    }

    if (guardian != null) {
      if (guardian.houseName != null &&
          guardian.houseName!.trim().isNotEmpty &&
          guardian.houseName != student.address) {
        parts.add(guardian.houseName!.trim());
      }
      if (guardian.street != null && guardian.street!.trim().isNotEmpty) {
        parts.add(guardian.street!.trim());
      }
      if (guardian.landmark != null && guardian.landmark!.trim().isNotEmpty) {
        parts.add('Near ${guardian.landmark!.trim()}');
      }
      if (guardian.city != null && guardian.city!.trim().isNotEmpty) {
        parts.add(guardian.city!.trim());
      }
      if (guardian.district != null &&
          guardian.district!.trim().isNotEmpty &&
          guardian.district != guardian.city) {
        parts.add(guardian.district!.trim());
      }
      if (guardian.state != null && guardian.state!.trim().isNotEmpty) {
        parts.add(guardian.state!.trim());
      }
      if (guardian.pincode != null && guardian.pincode!.trim().isNotEmpty) {
        parts.add('PIN: ${guardian.pincode!.trim()}');
      }
    }

    final fullAddress = parts.isNotEmpty
        ? parts.join(', ')
        : (student.address ?? 'No address provided');

    return _buildSectionCard(
      title: 'RESIDENTIAL ADDRESS',
      icon: Icons.home_rounded,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fullAddress,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── HELPER WIDGETS ───────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 12.5,
                  color: onTap != null ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(height: 1, thickness: 1, color: AppColors.divider),
    );
  }
}
