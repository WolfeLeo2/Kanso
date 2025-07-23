import 'package:flutter/cupertino.dart';
import 'package:kanso/models/event.dart';

class TaskList extends StatelessWidget {
  final List<Event> events;
  final DateTime selectedDay;

  const TaskList({required this.events, required this.selectedDay, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todayEvents = events.where((event) =>
      event.dateTime.year == selectedDay.year &&
      event.dateTime.month == selectedDay.month &&
      event.dateTime.day == selectedDay.day
    ).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.07),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: todayEvents.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Text('No tasks for today', style: TextStyle(color: CupertinoColors.systemGrey2)),
              )
            ]
          : todayEvents.map((event) {
              return Column(
                children: [
                  _TaskListItem(event: event),
                  if (event != todayEvents.last)
                    Container(
                      height: 1,
                      color: CupertinoColors.systemGrey4,
                      margin: const EdgeInsets.only(left: 56),
                    ),
                ],
              );
            }).toList(),
      ),
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final Event event;
  const _TaskListItem({required this.event});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    if ((event.notes ?? '').toLowerCase().contains('birthday')) {
      icon = CupertinoIcons.gift_fill;
      iconColor = CupertinoColors.systemRed;
    } else if ((event.notes ?? '').toLowerCase().contains('wake')) {
      icon = CupertinoIcons.sun_max_fill;
      iconColor = CupertinoColors.systemYellow;
    } else {
      icon = CupertinoIcons.circle;
      iconColor = CupertinoColors.systemGrey;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              event.title,
              style: TextStyle(
                color: CupertinoColors.black,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            event.dateTime.hour.toString().padLeft(2, '0') + ':' + event.dateTime.minute.toString().padLeft(2, '0'),
            style: TextStyle(
              color: CupertinoColors.systemGrey2,
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
