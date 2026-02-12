import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/widgets/common_button.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/stop_management_provider.dart';
import 'package:school_bus_tracker/features/tracking/presentation/provider/student_provider.dart';

class AddStudentDialog extends StatefulWidget {
  final int routeId;
  final int stopId;

  const AddStudentDialog({
    super.key,
    required this.routeId,
    required this.stopId,
  });

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  @override
  void initState() {
    super.initState();

    final provider = context.read<StudentProvider>();
    provider.clearSelection();
    provider.fetchStudentsByRouteId(routeId: widget.routeId);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height * 0.75),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            children: [
              /// Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Select Students',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(flex: 2),
                ],
              ),

              const SizedBox(height: 12),

              /// List
              Expanded(
                child: Consumer<StudentProvider>(
                  builder: (context, provider, _) {
                    if (provider.students.isEmpty) {
                      return const Center(child: Text("No students found"));
                    }

                    return ListView.builder(
                      itemCount: provider.students.length,
                      itemBuilder: (context, index) {
                        final student = provider.students[index];
                        final isSelected = provider.selectedStudentIds.contains(
                          student.id,
                        );

                        return GestureDetector(
                          onTap: () {
                            provider.toggleStudentSelection(student.id);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.black.withAlpha(30)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                /// Avatar
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.white,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                /// Name + Guardian
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        student.guardianName ?? "Not mentioned",
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// Custom Checkbox
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey,
                                      width: 1.5,
                                    ),
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              /// Submit Button
              Consumer<StudentProvider>(
                builder: (context, provider, _) {
                  return CommonButton(
                    title: provider.isSubmitting ? "Submitting..." : "Submit",
                    onTap: provider.isSubmitting
                        ? null
                        : () async {
                            final success = await provider
                                .addSelectedStudentsToStop(widget.stopId);
                            if (!context.mounted) return;
                            await context
                                .read<StopManagementProvider>()
                                .fetchSingleStop(widget.stopId);

                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
