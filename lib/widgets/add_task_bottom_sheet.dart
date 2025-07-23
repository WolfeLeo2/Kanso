import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kanso/models/event.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function(Event) onTaskCreated;
  final DateTime initialDate;
  final Event? eventToEdit;

  const AddTaskBottomSheet({
    Key? key,
    required this.onTaskCreated,
    required this.initialDate,
    this.eventToEdit,
  }) : super(key: key);

  @override
  _AddTaskBottomSheetState createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late TaskType _selectedTaskType;
  late TimeOfDay _selectedStartTime;
  late TimeOfDay _selectedEndTime;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      _titleController = TextEditingController(text: widget.eventToEdit!.title);
      _notesController = TextEditingController(text: widget.eventToEdit!.notes ?? '');
      _selectedStartTime = TimeOfDay.fromDateTime(widget.eventToEdit!.dateTime);
      _selectedEndTime = widget.eventToEdit!.endTime != null 
          ? TimeOfDay.fromDateTime(widget.eventToEdit!.endTime!) 
          : TimeOfDay.fromDateTime(widget.eventToEdit!.dateTime.add(const Duration(hours: 1)));
      _selectedDate = widget.eventToEdit!.dateTime;
      _selectedTaskType = widget.eventToEdit!.taskType;
    } else {
      _titleController = TextEditingController();
      _notesController = TextEditingController();
      final now = TimeOfDay.now();
      _selectedStartTime = now;
      // Ensure minutes are within valid range (0-59)
      final endMinute = (now.minute + 30) % 60;
      final endHour = now.hour + ((now.minute + 30) ~/ 60);
      _selectedEndTime = TimeOfDay(hour: endHour, minute: endMinute);
      _selectedDate = widget.initialDate;
      _selectedTaskType = TaskType.task;
    }
  }

  String _formatTimeRange(TimeOfDay start, TimeOfDay end) {
    final now = DateTime.now();
    final startDate = DateTime(
      now.year,
      now.month,
      now.day,
      start.hour,
      start.minute,
    );
    final endDate = DateTime(
      now.year,
      now.month,
      now.day,
      end.hour,
      end.minute,
    );
    final startStr = TimeOfDay.fromDateTime(startDate).format(context);
    final endStr = TimeOfDay.fromDateTime(endDate).format(context);
    return '$startStr - $endStr';
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initialTime = isStart ? _selectedStartTime : _selectedEndTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedStartTime = picked;
          // Optionally, auto-adjust end time if it's before start
          if (_selectedEndTime.hour < picked.hour ||
              (_selectedEndTime.hour == picked.hour &&
                  _selectedEndTime.minute <= picked.minute)) {
            _selectedEndTime = TimeOfDay(
              hour: (picked.hour + 1) % 24,
              minute: picked.minute,
            );
          }
        } else {
          _selectedEndTime = picked;
        }
      });
    }
  }

  void _handleSave() {
    if (_titleController.text.trim().isEmpty) return;

    final startDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedStartTime.hour,
      _selectedStartTime.minute,
    );

    final endDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedEndTime.hour,
      _selectedEndTime.minute,
    );

    final event = Event(
      id: widget.eventToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      dateTime: startDateTime,
      endTime: endDateTime,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      taskType: _selectedTaskType,
      isCompleted: widget.eventToEdit?.isCompleted ?? false,
    );

    widget.onTaskCreated(event);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 12, // reduced from 16
            right: 12, // reduced from 16
            top: 10, // reduced from 16
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create a new task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ), // smaller font
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // reduced from 24
                const Text(
                  'Title',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 14,
                  ), // smaller font
                ),
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  style: const TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 15,
                  ), // smaller font
                  decoration: InputDecoration(
                    hintText: 'Brief Project with team',
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                    ), // reduced
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: CupertinoColors.systemGrey4,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: _selectedTaskType.color,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6), // reduced spacing
                // Type chips row (moved up, no label)
                Wrap(
                  spacing: 6.0, // reduced from 8
                  runSpacing: 6.0,
                  children: TaskType.values.map((type) {
                    final isSelected = _selectedTaskType == type;
                    return ChoiceChip(
                      label: Text(
                        type.name,
                        style: const TextStyle(fontSize: 13),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTaskType = type;
                          });
                        }
                      },
                      selectedColor: type.color.withOpacity(0.8),
                      backgroundColor: type.color.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : CupertinoColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Time',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6), // reduced from 8
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickTime(isStart: true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ), // reduced
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: CupertinoColors.systemGrey4,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                color: CupertinoColors.systemGrey,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedStartTime.format(context),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: CupertinoColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // reduced from 12
                    const Text(
                      '-',
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _pickTime(isStart: false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: CupertinoColors.systemGrey4,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time,
                                color: CupertinoColors.systemGrey,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _selectedEndTime.format(context),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: CupertinoColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Removed duplicate time indicator here
                const SizedBox(height: 10),
                const Text(
                  'Details',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 14,
                  ),
                ),
                TextField(
                  controller: _notesController,
                  style: const TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Add some details about your task...',
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: CupertinoColors.systemGrey4,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: _selectedTaskType.color,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: _handleSave,
                    color: _selectedTaskType.color,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ), // reduced
                    child: const Text(
                      'Create Task',
                      style: TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
