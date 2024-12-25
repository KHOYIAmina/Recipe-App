import 'dart:async';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:recipe_app/Provider/notifs_provider.dart';
import 'package:recipe_app/Utils/constants.dart';
import 'package:recipe_app/Widget/calendar_edit_dialog.dart';
import 'package:table_calendar/table_calendar.dart';

class DateValidatorWidget extends StatefulWidget {
  final DateTime date;
  final String recipeId;
  final VoidCallback onRefresh;

  const DateValidatorWidget({
    super.key,
    required this.date,
    required this.recipeId,
    required this.onRefresh,
  });

  @override
  _DateValidatorWidgetState createState() => _DateValidatorWidgetState();
}

class _DateValidatorWidgetState extends State<DateValidatorWidget> {
  final NotifsProvider providerNotifs = NotifsProvider();
  late ValueNotifier<bool> isDateValidNotifier;
  late DateTime initialDate;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    isDateValidNotifier = ValueNotifier(false);
    checkDate();

    timer = Timer.periodic(const Duration(seconds: 0), (_) {
      checkDate();
    });
    initialDate = widget.date;
  }

  @override
  void dispose() {
    timer?.cancel();
    isDateValidNotifier.dispose();
    super.dispose();
  }

  Future<void> checkDate() async {
    bool isValid = await providerNotifs.isBeforeToday(widget.date);
    isDateValidNotifier.value = isValid;
  }

  void delete(BuildContext context, DateTime date, String idDocs) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext ctx) {
        return CupertinoAlertDialog(
          title: const Text('Please Confirm'),
          content: const Text('Are you sure to remove the notification?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                providerNotifs.removeDateFromFirebase(date, idDocs);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification removed successfully'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: const Text('Yes'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  Time timeOfDayToTime(TimeOfDay timeOfDay) {
    return Time(hour: timeOfDay.hour, minute: timeOfDay.minute);
  }

  Future<void> selectTime(
      BuildContext context, String recipeId, DateTime mealDate) async {
    final now = DateTime.now();
    final isToday = isSameDay(mealDate, now);

    Time initialTime = isToday
        ? timeOfDayToTime(TimeOfDay.fromDateTime(now))
        : timeOfDayToTime(TimeOfDay.fromDateTime(mealDate));

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

          DateTime updatedDateTime = DateTime(
            mealDate.year,
            mealDate.month,
            mealDate.day,
            newTime.hour,
            newTime.minute,
          );

          providerNotifs.updateTimeInFirebase(
              recipeId, updatedDateTime, widget.onRefresh);

          Navigator.of(context).pop();
          widget.onRefresh();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This meal has been updated'),
              backgroundColor: Colors.green, // Custom background color
              duration: Duration(seconds: 3),
            ),
          );
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
    return Container(
      margin: const EdgeInsets.only(top: 45, left: 25),
      child: ValueListenableBuilder<bool>(
        valueListenable: isDateValidNotifier,
        builder: (context, isDateValid, child) {
          return Row(
            children: [
              GestureDetector(
                onTap: isDateValid
                    ? () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext cont) {
                            return CupertinoActionSheet(
                              actions: [
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    // Show the dialog using showModalBottomSheet or showCupertinoModalPopup
                                    showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CalendarEditDialog(
                                          onDateSelected: (selectedDate) {
                                            setState(() {
                                              initialDate = selectedDate;
                                            });
                                          },
                                          recipeId: widget.recipeId,
                                          initialDate: widget.date,
                                          onRefresh: widget.onRefresh,
                                        );
                                      },
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(CupertinoIcons.calendar,
                                          color: kprimaryColor),
                                      SizedBox(width: 8),
                                      Text(
                                        'Change Date',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                ),
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    selectTime(
                                        context, widget.recipeId, widget.date);
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(CupertinoIcons.time,
                                          color: kprimaryColor),
                                      SizedBox(width: 8),
                                      Text(
                                        'Change Time',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w400),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                              cancelButton: CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.of(cont).pop();
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    : null,
                child: Icon(
                  Icons.edit,
                  color: isDateValid ? Colors.green : Colors.grey,
                  size: 25,
                ),
              ),
              GestureDetector(
                onTap: isDateValid
                    ? () {
                        delete(context, widget.date, widget.recipeId);
                      }
                    : null,
                child: Icon(
                  Icons.delete,
                  color: isDateValid ? Colors.red : Colors.grey,
                  size: 25,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
