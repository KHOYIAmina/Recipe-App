import 'package:flutter/material.dart';
import 'package:recipe_app/Utils/constants.dart';
import 'package:recipe_app/services/notifs_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarDialog extends StatefulWidget {
  const CalendarDialog({
    super.key,
    required this.onDateSelected,
    required this.recipeId,
  });

  final Function(List<DateTime>) onDateSelected;
  final String recipeId;

  @override
  _CalendarDialogState createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<CalendarDialog> {
  late List<DateTime> _tempSelectedDays;
  late List<DateTime> _datesBeforeToday;
  DateTime _focusedDay = DateTime.now();
  final NotifsService providerNotifs = NotifsService();

  @override
  void initState() {
    super.initState();
    _tempSelectedDays = [];
    _datesBeforeToday = [];
    _fetchSelectedDates();
    _fetchDatesBeforeToday();
  }

  void _fetchDatesBeforeToday() async {
    try {
      List<DateTime> dates =
          await providerNotifs.getSelectedDatesForRecipe(widget.recipeId);
      setState(() {
        _datesBeforeToday = dates;
      });
    } catch (e) {
      print('Error fetching dates before today: $e');
    }
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

  void _fetchSelectedDates() async {
    try {
      var collection = FirebaseFirestore.instance.collection('selected_dates');
      var querySnapshot =
          await collection.where('recipeId', isEqualTo: widget.recipeId).get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _tempSelectedDays = querySnapshot.docs
              .map((doc) {
                var timestamp = doc['date'] as Timestamp;
                return timestamp.toDate();
              })
              .whereType<DateTime>()
              .toList();
        });
      }
    } catch (e) {
      print('Error fetching selected dates: $e');
    }
  }

  void _saveSelectedDatesToFirebase() {
    providerNotifs.saveSelectedDatesToFirebase(
        widget.recipeId, _tempSelectedDays);
  }

  void _removeDateFromFirebase(DateTime date) {
    providerNotifs.removeDateFromFirebase(date, widget.recipeId);
  }

  Time timeOfDayToTime(TimeOfDay timeOfDay) {
    return Time(hour: timeOfDay.hour, minute: timeOfDay.minute);
  }

  TimeOfDay timeToTimeOfDay(Time time) {
    return TimeOfDay(hour: time.hour, minute: time.minute);
  }

  Future<void> _selectTime(BuildContext context, DateTime date) async {
    final now = DateTime.now();
    final isToday = isSameDay(date, now);

    Time initialTime = isToday
        ? timeOfDayToTime(TimeOfDay.fromDateTime(now))
        : timeOfDayToTime(TimeOfDay.fromDateTime(date));

    Navigator.of(context)
        .push(
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
            if (!_tempSelectedDays.any((d) => isSameDay(d, date))) {
              _tempSelectedDays.add(DateTime(
                date.year,
                date.month,
                date.day,
                newTime.hour,
                newTime.minute,
              ));
            } else {
              _tempSelectedDays = _tempSelectedDays.map((d) {
                if (isSameDay(d, date)) {
                  return DateTime(
                    d.year,
                    d.month,
                    d.day,
                    newTime.hour,
                    newTime.minute,
                  );
                }
                return d;
              }).toList();
            }
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
    )
        .then((_) {
      setState(() {
        if (!_tempSelectedDays.any((d) => isSameDay(d, date))) {}
      });
    });
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
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                  ),
                  leftChevronIcon: Icon(
                    Icons.arrow_left,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                  rightChevronIcon: Icon(
                    Icons.arrow_right,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                    selectedBuilder: (context, day, focusedDay) {
                  return FutureBuilder<bool>(
                    future: _changeEtatOfCooking(day),
                    builder: (context, snapshot) {
                      bool isCooking = snapshot.data ?? false;
                      DateTime now = DateTime.now();
                      DateTime startOfDay =
                          DateTime(day.year, day.month, day.day);
                      DateTime selectedDateTime = DateTime(
                          day.year, day.month, day.day, day.hour, day.minute);
                      print(focusedDay);
                      bool isToday = startOfDay.year == now.year &&
                          startOfDay.month == now.month &&
                          startOfDay.day == now.day;

                      var dateWithTime = {_tempSelectedDays[0]};

                      // Check if the selected time (today) is in the future
                      bool isFutureTime = (dateWithTime.first.hour > now.hour ||
                          (dateWithTime.first.hour == now.hour &&
                              dateWithTime.first.hour > now.minute));
                      print(isFutureTime);
                      print(
                          'isFutureTime: $isFutureTime, selectedDateTime.hour: ${selectedDateTime.hour}, now.hour: ${now.hour}');
                      bool isBeforeToday = startOfDay
                          .isBefore(DateTime(now.year, now.month, now.day));
                      bool isSelectedDate = _tempSelectedDays.any(
                          (selectedDate) =>
                              isSameDay(selectedDate, startOfDay));

                      // Case: Today and in the future
                      if (isToday && isFutureTime) {
                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary, // Highlight future time today with kprimaryColor
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      // Case: Today but passed (before now)
                      if (isBeforeToday ||
                          (isToday && selectedDateTime.isBefore(now))) {
                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromRGBO(158, 158, 158, 1),
                            border: Border.all(
                              color: isCooking ? Colors.green : Colors.red,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      // Case: Selected date, before today or time
                      if (isBeforeToday ||
                          (isToday && selectedDateTime.isBefore(now)) &&
                              isSelectedDate) {
                        return Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCooking ? Colors.green : Colors.red,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      // Default case for selectable dates
                      return Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  );
                }),
                selectedDayPredicate: (day) {
                  return _tempSelectedDays
                      .any((selectedDate) => isSameDay(selectedDate, day));
                },
                enabledDayPredicate: (day) {
                  return day.isAfter(
                        DateTime.now().subtract(const Duration(days: 1)),
                      ) ||
                      _tempSelectedDays
                          .any((selectedDate) => isSameDay(selectedDate, day));
                },
                onDaySelected: (selectedDay, focusedDay) async {
                  setState(() {
                    _focusedDay = focusedDay;
                  });

                  final alreadySelected =
                      _tempSelectedDays.any((d) => isSameDay(d, selectedDay));

                  if (alreadySelected) {
                    setState(() {
                      _tempSelectedDays
                          .removeWhere((d) => isSameDay(d, selectedDay));
                    });
                    _removeDateFromFirebase(selectedDay);
                  } else {
                    await _selectTime(context, selectedDay);
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
                    onPressed: () {
                      widget.onDateSelected(_tempSelectedDays);
                      Navigator.of(context).pop();
                      _saveSelectedDatesToFirebase();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
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
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Theme.of(context).colorScheme.primary,
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
