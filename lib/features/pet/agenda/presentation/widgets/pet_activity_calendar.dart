import 'package:flutter/material.dart';
import 'package:scannutplus/features/pet/data/models/pet_event_type.dart';
import 'package:scannutplus/pet/agenda/pet_event.dart'; // Legacy Model used in UI
import 'package:intl/intl.dart';

class PetActivityCalendar extends StatefulWidget {
  final List<PetEvent> events;
  final Function(DateTime) onDateSelected;

  const PetActivityCalendar({
    super.key,
    required this.events,
    required this.onDateSelected,
  });

  @override
  State<PetActivityCalendar> createState() => _PetActivityCalendarState();
}

class _PetActivityCalendarState extends State<PetActivityCalendar> {
  DateTime _focusedMonth = DateTime.now();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + offset);
    });
  }

  Map<int, int> _getEventsForMonth(DateTime month) {
    final Map<int, int> eventsPerDay = {};
    for (var event in widget.events) {
      if (event.startDateTime.year == month.year && event.startDateTime.month == month.month) {
        final day = event.startDateTime.day;
        eventsPerDay[day] = (eventsPerDay[day] ?? 0) + 1;
      }
    }
    return eventsPerDay;
  }

  @override
  Widget build(BuildContext context) {
    final eventCounts = _getEventsForMonth(_focusedMonth);
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstDayOfWeek = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday; // 1=Mon, 7=Sun
    // Adjust material DateUtils weekday (1..7) to standard calendar grid (usually Sun=0 or Mon=0).
    // Let's assume Mon=1, Sun=7. If we want Sun as column 0, we shift.
    // Standard Material Calendar starts Mon? Let's stick to Mon-Sun for consistency or check locale.
    // For simplicity, let's just render a grid.

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => _changeMonth(-1),
              ),
              Text(
                DateFormat('MMMM yyyy', 'pt_BR').format(_focusedMonth).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Days of Week Headers (PT-BR hardcoded for speed as requested, or l10n later)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB']
                .map((day) => Text(day, style: const TextStyle(color: Colors.grey, fontSize: 12)))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Calendar Grid
          Expanded( // Or SizedBox/AspectRatio if inside scroll
             child: GridView.builder(
               shrinkWrap: true, // Important for Modal
               physics: const NeverScrollableScrollPhysics(),
               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                 crossAxisCount: 7,
                 childAspectRatio: 1.0,
               ),
               itemCount: 42, // Fixed grid size 6 rows * 7 cols to correspond to max weeks
               itemBuilder: (context, index) {
                 // Calculate actual day offset
                 // firstDayOfWeek: 1=Mon...7=Sun.
                 // We want DOM(Sun) to be index 0?
                 // DateTime.sunday is 7. 
                 // If our header is DOM, SEG... DOM is weekday 7.
                 // So if firstDayOfMonth.weekday is 7 (Sun), offset should be 0.
                 // If firstDayOfMonth is 1 (Mon), offset should be 1.
                 // offset = (firstDay.weekday % 7).
                 
                 final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
                 final offset = firstDay.weekday % 7;
                 
                 final dayNum = index - offset + 1;
                 
                 if (dayNum < 1 || dayNum > daysInMonth) {
                   return const SizedBox.shrink();
                 }
                 
                 final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
                 final count = eventCounts[dayNum] ?? 0;
                 final isSelected = DateUtils.isSameDay(date, _selectedDate);
                 final isToday = DateUtils.isSameDay(date, DateTime.now());
                 
                 return GestureDetector(
                   onTap: () {
                     setState(() => _selectedDate = date);
                     widget.onDateSelected(date);
                   },
                   child: Container(
                     margin: const EdgeInsets.all(4),
                     decoration: BoxDecoration(
                       color: isSelected ? Colors.orange : (isToday ? Colors.white10 : Colors.transparent),
                       shape: BoxShape.circle,
                     ),
                     child: Stack(
                       alignment: Alignment.center,
                       children: [
                         Text(
                           "$dayNum",
                           style: TextStyle(
                             color: isSelected ? Colors.black : Colors.white,
                             fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                           ),
                         ),
                         if (count > 0 && !isSelected)
                           Positioned(
                             bottom: 4,
                             child: Container(
                               width: 4,
                               height: 4,
                               decoration: const BoxDecoration(
                                 color: Colors.orange,
                                 shape: BoxShape.circle,
                               ),
                             ),
                           ),
                          if (count > 0 && isSelected)
                           Positioned(
                             top: 0,
                             right: 0,
                             child: Container(
                               padding: const EdgeInsets.all(2),
                               decoration: const BoxDecoration(
                                 color: Colors.black,
                                 shape: BoxShape.circle,
                               ),
                               child: Text(
                                  count > 9 ? '9+' : '$count',
                                  style: const TextStyle(color: Colors.white, fontSize: 8),
                               ),
                             ),
                           ),
                       ],
                     ),
                   ),
                 );
               },
             ),
          ),
          // Activity Legend/Summary
          Padding(
             padding: const EdgeInsets.only(top: 16),
             child: Text(
               "[CALENDAR_TRACE] Frequência calculada. $daysInMonth dias processados.",
               style: TextStyle(color: Colors.grey.shade700, fontSize: 10),
             ),
          )
        ],
      ),
    );
  }
}
