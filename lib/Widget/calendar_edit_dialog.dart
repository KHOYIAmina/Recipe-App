import 'package:flutter/material.dart';
import 'package:recipe_app/Provider/notifs_provider.dart';
import 'package:recipe_app/Utils/constants.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEditDialog extends StatefulWidget {
  const CalendarEditDialog({
    super.key,
    required this.onDateSelected,
    required this.recipeId,
    required this.initialDate,
    required this.onRefresh, // Add a parameter for the initial selected date
  });

  final Function(DateTime) onDateSelected;
  final String recipeId;
  final DateTime initialDate;
  final VoidCallback onRefresh; // This is the date passed to the dialog

  @override
  _CalendarDialogState createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<CalendarEditDialog> {
  late DateTime _selectedDay;
  DateTime _focusedDay = DateTime.now();
  final NotifsProvider providerNotifs = NotifsProvider();

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate; // Initialize with the passed date
  }

  bool get _isDateChanged {
    // Check if the selected date is different from the initial date
    return !isSameDay(_selectedDay, widget.initialDate);
  }

  Future<bool> _changeEtatOfCooking(DateTime date) async {
    try {
      Map<String, dynamic> valueOfCooking =
          await providerNotifs.checkIsCooking(widget.recipeId, date);
      return valueOfCooking['isCooking'] ?? false;
    } catch (e) {
      print('Error checking cooking status: $e');
      return false;
    }
  }

  void _saveSelectedDateToFirebase() {
    providerNotifs.updateDatesByRecipeId(
        widget.recipeId, _selectedDay, widget.onRefresh);
    widget.onRefresh();
    Navigator.of(context).pop();
  }

  Time timeOfDayToTime(TimeOfDay timeOfDay) {
    return Time(hour: timeOfDay.hour, minute: timeOfDay.minute);
  }

  Future<void> _selectTime(BuildContext context, DateTime date) async {
    final now = DateTime.now();
    final isToday = isSameDay(date, now);

    Time initialTime = isToday
        ? timeOfDayToTime(TimeOfDay.fromDateTime(now))
        : timeOfDayToTime(TimeOfDay.fromDateTime(date));

    Navigator.of(context).push(
      showPicker(
        context: context,
        value: initialTime,
        onChange: (Time newTime) {
          if (isToday &&
              (newTime.hour < now.hour ||
                  (newTime.hour == now.hour && newTime.minute < now.minute))) {
            return;
          }

          setState(() {
            _selectedDay = DateTime(
              date.year,
              date.month,
              date.day,
              newTime.hour,
              newTime.minute,
            );
          });
        },
        is24HrFormat: true,
        disableHour: false,
        disableMinute: false,
        okText: 'Done',
        cancelText: 'Cancel',
        minHour: isToday ? now.hour.toDouble() : 0.0,
        minMinute: isToday ? now.minute.toDouble() : 0.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 350,
              height: 330,
              child: TableCalendar(
                rowHeight: 40,
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: _focusedDay,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kprimaryColor,
                    fontSize: 20,
                  ),
                  leftChevronIcon: Icon(
                    Icons.arrow_left,
                    color: kprimaryColor,
                    size: 30,
                  ),
                  rightChevronIcon: Icon(
                    Icons.arrow_right,
                    color: kprimaryColor,
                    size: 30,
                  ),
                ),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: kprimaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  selectedBuilder: (context, day, focusedDay) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: kprimaryColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) async {
                  if (selectedDay.isAfter(
                    DateTime.now().subtract(const Duration(days: 1)),
                  )) {
                    setState(() {
                      _focusedDay = focusedDay;
                      _selectedDay = selectedDay;
                    });

                    // If the selected day is not the initial day, show the time picker
                    if (!isSameDay(selectedDay, widget.initialDate)) {
                      await _selectTime(context, selectedDay);
                    }
                  }
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                },
              ),
            ),
            Transform.translate(
              offset: const Offset(12, 0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _isDateChanged
                        ? () {
                            widget.onDateSelected(_selectedDay);
                            Navigator.of(context).pop();
                            _saveSelectedDateToFirebase();
                          }
                        : null, // Disable the button if the date hasn't changed
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kprimaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 5,
                      ),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 37),
                    ),
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: kprimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
