import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:kanso/theme/app_theme.dart';

import 'package:kanso/models/event.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;
  final List<Event> events;

  const CalendarWidget({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    required this.events,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(day, widget.selectedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  widget.onDaySelected(selectedDay);
                },
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                    color: CupertinoColors.label,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedTextStyle: const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendTextStyle: TextStyle(
                    color: CupertinoColors.systemRed,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  titleTextStyle: AppTheme.title2,
                  leftChevronIcon: const Icon(
                    CupertinoIcons.chevron_left,
                    color: AppTheme.primaryColor,
                  ),
                  rightChevronIcon: const Icon(
                    CupertinoIcons.chevron_right,
                    color: AppTheme.primaryColor,
                  ),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: AppTheme.subheadline.copyWith(
                    color: CupertinoColors.secondaryLabel,
                  ),
                  weekendStyle: AppTheme.subheadline.copyWith(
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.mediumPadding),
            // Event list will go here
            CupertinoListSection.insetGrouped(
              margin: EdgeInsets.zero,
              children: widget.events.map((event) => _buildEventItem(event)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventItem(Event event) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemBackground,
          borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        ),
        child: CupertinoListTile(
          leading: Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: event.isCompleted 
                  ? CupertinoColors.systemGreen 
                  : AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          title: Text(
            event.title,
            style: AppTheme.body.copyWith(
              decoration: event.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            '${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')}',
            style: AppTheme.footnote,
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // Toggle completion status
            },
            child: Icon(
              event.isCompleted
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              color: event.isCompleted
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.tertiaryLabel,
            ),
          ),
        ),
      ),
    );
  }
}
