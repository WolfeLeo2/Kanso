import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:kanso/models/event.dart';

class CalendarStrip extends StatelessWidget {
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDaySelected;
  final List<Event> events;

  const CalendarStrip({
    required this.selectedDay,
    required this.onDaySelected,
    required this.events,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: days.map((date) {
          final isSelected = DateUtils.isSameDay(date, selectedDay);
          final dayEvents = events.where((event) => DateUtils.isSameDay(event.dateTime, date)).toList();
          final taskTypes = dayEvents.map((e) => e.taskType).toSet();

          return GestureDetector(
            onTap: () => onDaySelected(date),
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                color: isSelected ? CupertinoColors.black : CupertinoColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
              child: Column(
                children: [
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      color: isSelected ? CupertinoColors.white : CupertinoColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('E').format(date).toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? CupertinoColors.white : CupertinoColors.systemGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Dots for event types
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: taskTypes.map((type) {
                      return Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: type.color,
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
