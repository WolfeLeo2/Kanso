import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:kanso/widgets/add_task_bottom_sheet.dart';
import 'package:kanso/models/event.dart';
import 'package:kanso/widgets/calendar_task_card.dart';
import 'package:intl/intl.dart';
import 'package:kanso/utils/database_helper.dart';

// QuickChip widget for date selection
class QuickChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  const QuickChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.12) : Colors.white10,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.blue[200]! : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white70, size: 18),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Event> _events = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> _loadEvents() async {
    final events = await _dbHelper.getEvents();
    setState(() {
      _events = events;
    });
  }

  void _showAddTaskSheet({Event? eventToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddTaskBottomSheet(
        initialDate: _selectedDay,
        eventToEdit: eventToEdit,
        onTaskCreated: (updatedEvent) async {
          if (eventToEdit != null) {
            await _dbHelper.updateEvent(updatedEvent);
          } else {
            await _dbHelper.insertEvent(updatedEvent);
          }
          await _loadEvents();
        },
      ),
    );
  }

  void _handleEditEvent(Event event) {
    _showAddTaskSheet(eventToEdit: event);
  }

  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEvents();
  }

  void _handleTaskCompletion(Event event, bool isCompleted) async {
    final updated = event.copyWith(isCompleted: isCompleted);
    await _dbHelper.updateEvent(updated);
    await _loadEvents();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      return event.dateTime.year == day.year &&
          event.dateTime.month == day.month &&
          event.dateTime.day == day.day;
    }).toList();
  }

  Widget _buildProgressTracker() {
    final todayEvents = _getEventsForDay(_selectedDay);
    if (todayEvents.isEmpty) {
      return const SizedBox.shrink(); // Don't show progress if no tasks
    }

    final completedTasks = todayEvents.where((e) => e.isCompleted).length;
    final totalTasks = todayEvents.length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
          '$completedTasks/$totalTasks tasks completed',
          style: const TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        GradientProgressBar(progress: progress),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekday = DateFormat('EEE').format(_selectedDay);
    final fullDate = DateFormat('MMMM d, y').format(_selectedDay);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        bottom: false,
        top: true,
        child: Stack(
          children: [
            // Background content (Header, Summary)
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            Padding(
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      top: 10.0,
                      bottom: 18.0,
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            weekday,
                                  style: const TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: CupertinoColors.systemRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            fullDate.split(',')[0],
                                  style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            fullDate.split(',')[1].trim(),
                                  style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                            // TODO: Add your avatar image to assets/ and uncomment the line below
                            // const CircleAvatar(
                            //   radius: 14,
                            //   backgroundImage: AssetImage('assets/avatar.png'),
                            // ),
                      const SizedBox(width: 8),
                      RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 20,
                                ),
                          children: [
                                  TextSpan(text: 'Good morning, '),
                            TextSpan(
                                    text: 'user_name.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Builder(
                            builder: (context) {
                              final today = DateTime.now();
                              final todayEvents = _events.where((e) {
                                return e.dateTime.year == today.year &&
                                    e.dateTime.month == today.month &&
                                    e.dateTime.day == today.day;
                              }).toList();

                              // Only count incomplete tasks in the summary
                              final meetingCount = todayEvents
                                  .where((e) => e.taskType == TaskType.meeting && !e.isCompleted)
                                  .length;
                              final taskCount = todayEvents
                                  .where((e) => e.taskType == TaskType.task && !e.isCompleted)
                                  .length;
                              final habitCount = todayEvents
                                  .where((e) => e.taskType == TaskType.habit && !e.isCompleted)
                                  .length;

                              if (todayEvents.isEmpty) {
                                return RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: CupertinoColors.systemGrey,
                                      fontSize: 28,
                                      fontWeight: FontWeight.normal,
                                      height: 1.3,
                                      fontFamily: 'SF Pro',
                                    ),
                                    text: "You have no events scheduled for today.\n",
                                  ),
                                );
                              }

                              return RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 28,
                                    fontWeight: FontWeight.normal,
                                    height: 1.3,
                                    fontFamily: 'SF Pro',
                                  ),
                                  children: [
                                  const TextSpan(text: 'You have '),
                                    const WidgetSpan(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.0,
                                        ),
                                      child: Icon(
                                        CupertinoIcons.calendar,
                                        size: 24,
                                          color: CupertinoColors.activeBlue,
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                      text:
                                          '$meetingCount meeting${meetingCount == 1 ? '' : 's'}',
                                      style: const TextStyle(
                                        color: CupertinoColors.activeBlue,
                                        fontWeight: FontWeight.bold,
                                  ),
                                    ),
                                    const TextSpan(text: ',\n'),
                                    const WidgetSpan(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.0,
                                        ),
                                      child: Icon(
                                          CupertinoIcons
                                              .check_mark_circled_solid,
                                        size: 24,
                                          color: CupertinoColors.activeGreen,
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                      text:
                                          '$taskCount task${taskCount == 1 ? '' : 's'}',
                                      style: const TextStyle(
                                        color: CupertinoColors.activeGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    const WidgetSpan(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 2.0),
                                        child: Icon(
                                          CupertinoIcons.time,
                                          size: 24,
                                          color: CupertinoColors.activeOrange,
                                        ),
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$habitCount habit${habitCount == 1 ? '' : 's'}',
                                      style: const TextStyle(
                                        color: CupertinoColors.activeOrange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                      const TextSpan(text: ' today. '),
                                    const TextSpan(
                                      text: "You're mostly free after 4 pm.",
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildProgressTracker(),
                      ],
                    ),
                  ),
                ],
              ), // End Column
            ), // End SingleChildScrollView
            // Draggable Sheet
            // Floating plus button logic
            _DraggableSheetWithAddButton(
              selectedDay: _selectedDay,
              onDaySelected: (day) {
                setState(() {
                  _selectedDay = day;
                });
              },
              onTaskCompletedChanged: _handleTaskCompletion,
              onEditEvent: _handleEditEvent,
              events: _events,
              showAddDialog: () => _showAddTaskSheet(),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Floating Draggable Sheet with Add Button ---
class _DraggableSheetWithAddButton extends StatefulWidget {
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final Function(Event, bool) onTaskCompletedChanged;
  final Function(Event) onEditEvent;
  final List<Event> events;
  final VoidCallback showAddDialog;

  const _DraggableSheetWithAddButton({
    Key? key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onTaskCompletedChanged,
    required this.onEditEvent,
    required this.events,
    required this.showAddDialog,
  }) : super(key: key);

  @override
  State<_DraggableSheetWithAddButton> createState() =>
      _DraggableSheetWithAddButtonState();
}

class _DraggableSheetWithAddButtonState
    extends State<_DraggableSheetWithAddButton> {
  final ValueNotifier<double> _extent = ValueNotifier(0.55);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            NotificationListener<DraggableScrollableNotification>(
              onNotification: (notification) {
                _extent.value = notification.extent;
                return false;
              },
              child: DraggableScrollableSheet(
                initialChildSize: 0.55,
                minChildSize: 0.55,
                maxChildSize: 1.0,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24.0),
                            topRight: Radius.circular(24.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10.0,
                              color: CupertinoColors.black.withOpacity(0.1),
                            ),
                          ],
                        ),
                        child: CalendarTaskCard(
                          selectedDay: widget.selectedDay,
                          onDaySelected: widget.onDaySelected,
                          onTaskCompletedChanged: widget.onTaskCompletedChanged,
                          onEditEvent: widget.onEditEvent,
                          events: widget.events,
                          scrollController: scrollController,
                        ),
                    );
                    },
              ),
            ),
            // Floating add button
            ValueListenableBuilder<double>(
              valueListenable: _extent,
              builder: (context, value, child) {
                if ((value - 1.0).abs() < 0.02) {
                  // Show only when fully expanded
                  return Positioned(
                    right: 24,
                    bottom: 32,
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 0,
                      color: CupertinoColors.activeBlue,
                      borderRadius: BorderRadius.circular(28),
                      child: Icon(
                        CupertinoIcons.add,
                        color: CupertinoColors.white,
                        size: 32,
                      ),
                      onPressed: widget.showAddDialog,
              ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        );
      },
    );
  }
}

class GradientProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  const GradientProgressBar({Key? key, required this.progress})
    : super(key: key);

  List<Color> _getGradientColors(double value) {
    if (value < 0.33) {
      // Red to Yellow
      return [Colors.red, Colors.orange];
    } else if (value < 0.66) {
      // Yellow to Green
      return [Colors.orange, Colors.yellow, Colors.green];
    } else {
      // Green to Blue
      return [Colors.green, Colors.blueAccent];
    }
  }

  @override
  Widget build(BuildContext context) {
    final barHeight = 8.0;
    final barRadius = 8.0;
    final gradientColors = _getGradientColors(progress);
    return ClipRRect(
      borderRadius: BorderRadius.circular(barRadius),
      child: SizedBox(
        height: barHeight,
        child: Stack(
                children: [
            // Background (neutral color)
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray,
                    ),
                  ),
            // Foreground (gradient progress)
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
