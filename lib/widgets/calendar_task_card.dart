import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kanso/models/event.dart';
import 'package:kanso/widgets/calendar_strip.dart';

class CalendarTaskCard extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;
  final List<Event> events;
  final void Function(Event, bool) onTaskCompletedChanged;
  final ScrollController scrollController;
  final Function(Event) onEditEvent;

  const CalendarTaskCard({
    required this.selectedDay,
    required this.onDaySelected,
    required this.events,
    required this.onTaskCompletedChanged,
    required this.scrollController,
    required this.onEditEvent,
    Key? key,
  }) : super(key: key);

  @override
  _CalendarTaskCardState createState() => _CalendarTaskCardState();
}

class _CalendarTaskCardState extends State<CalendarTaskCard> {
  final List<String> _expandedEventIds = [];

  @override
  Widget build(BuildContext context) {
    final todayEvents = widget.events
        .where(
          (event) =>
              event.dateTime.year == widget.selectedDay.year &&
              event.dateTime.month == widget.selectedDay.month &&
              event.dateTime.day == widget.selectedDay.day,
        )
        .toList();
    todayEvents.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar strip
        CalendarStrip(
          selectedDay: widget.selectedDay,
          onDaySelected: widget.onDaySelected,
          events: widget.events,
        ),
        // Task list
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: ListView.builder(
              controller: widget.scrollController,
              padding: EdgeInsets.zero, // Padding is handled by _TaskListItem
              itemCount: todayEvents.length,
              itemBuilder: (context, index) {
                final event = todayEvents[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GestureDetector(
                    onDoubleTap: () => widget.onEditEvent(event),
                    child: _TaskListItem(
                      event: event,
                      color: event.taskType.color,
                      onCompletedChanged: (isCompleted) =>
                          widget.onTaskCompletedChanged(event, isCompleted),
                      isExpanded: _expandedEventIds.contains(event.id),
                      onTap: () {
                        setState(() {
                          if (_expandedEventIds.contains(event.id)) {
                            _expandedEventIds.remove(event.id); // Collapse
                          } else {
                            _expandedEventIds.add(event.id); // Expand
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final Event event;
  final Color color;
  final void Function(bool) onCompletedChanged;
  final bool isExpanded;
  final VoidCallback onTap;

  const _TaskListItem({
    required this.event,
    required this.color,
    required this.onCompletedChanged,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final startTime = DateFormat('h:mm a').format(event.dateTime);
    final endTime = event.dateTime.add(
      const Duration(hours: 1),
    ); // Demo: 1 hour duration
    final endTimeStr = DateFormat('h:mm a').format(endTime);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time (outside card, smaller font)
            SizedBox(
              width: 48,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  startTime,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Card with colored bar inside
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.extraLightBackgroundGray,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Colored bar
                      Container(
                        width: 8,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                      ),
                      // Task content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 12,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: TextStyle(
                                    color: CupertinoColors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    decoration: event.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$startTime – $endTimeStr',
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey2,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              // Animated description section with constrained height
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child:
                                    isExpanded &&
                                        event.notes != null &&
                                        event.notes!.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxHeight: 100,
                                          ),
                                          child: SingleChildScrollView(
                                            child: Text(
                                              event.notes!,
                                              style: const TextStyle(
                                                color: CupertinoColors
                                                    .secondaryLabel,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Squircle Checkbox
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Center(
                          child: GestureDetector(
                            onTap: () => onCompletedChanged(!event.isCompleted),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: event.isCompleted
                                    ? color
                                    : CupertinoColors.extraLightBackgroundGray,
                                border: Border.all(
                                  color: event.isCompleted
                                      ? color
                                      : CupertinoColors.systemGrey4,
                                  width: 1.5,
                                ),
                              ),
                              child: event.isCompleted
                                  ? const Icon(
                                      CupertinoIcons.check_mark,
                                      color: CupertinoColors.white,
                                      size: 16,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
