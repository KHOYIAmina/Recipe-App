import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NotifsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> _notifications = [];
  List<Map<String, dynamic>> get notifications => _notifications;

  // Function to format DateTime to a string with milliseconds
  String formatDateWithMilliseconds(DateTime date) {
    var formatter = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
    return formatter.format(date);
  }

  // Function to check if a recipe is already selected based on its recipeId
  Future<bool> isRecipeSelected(String recipeId) async {
    try {
      var collection = _firestore.collection('selected_dates');
      var querySnapshot =
          await collection.where('recipeId', isEqualTo: recipeId).get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if recipe is selected: $e');
      return false;
    }
  }

  // Function to check if a given date is before today
  Future<bool> isBeforeToday(DateTime date) async {
    try {
      DateTime now = DateTime.now();

      DateTime nowWithNoSeconds =
          DateTime(now.year, now.month, now.day, now.hour, now.minute);
      DateTime dateWithNoSeconds =
          DateTime(date.year, date.month, date.day, date.hour, date.minute);

      return dateWithNoSeconds.isAtSameMomentAs(nowWithNoSeconds) ||
          !dateWithNoSeconds.isBefore(nowWithNoSeconds);
    } catch (e) {
      print('Error checking if date is before today: $e');
      return false;
    }
  }

  // Function to update the time for a recipeId in Firestore
  void updateTimeInFirebase(
      String recipeId, DateTime updatedDateTime, VoidCallback callback) async {
    try {
      var collection = FirebaseFirestore.instance.collection('selected_dates');

      var querySnapshot =
          await collection.where('recipeId', isEqualTo: recipeId).get();

      if (querySnapshot.docs.isEmpty) {
        print('No document found for recipeId $recipeId');
      }

      for (var doc in querySnapshot.docs) {
        var existingTimestamp = (doc['date'] as Timestamp).toDate();
        DateTime existingDate = DateTime(existingTimestamp.year,
            existingTimestamp.month, existingTimestamp.day);

        DateTime updatedDateTimeWithExistingDate = DateTime(
          existingDate.year,
          existingDate.month,
          existingDate.day,
          updatedDateTime.hour,
          updatedDateTime.minute,
        );

        Timestamp newTimestamp =
            Timestamp.fromDate(updatedDateTimeWithExistingDate);

        await doc.reference.update({'date': newTimestamp});
        callback();
      }
    } catch (e) {
      print('Error updating the time for recipeId $recipeId: $e');
    }
  }

  // Function to update all selected dates for a specific recipeId
  void updateDatesByRecipeId(
      String recipeId, DateTime updatedDateTime, VoidCallback callback) async {
    try {
      var collection = FirebaseFirestore.instance.collection('selected_dates');

      var querySnapshot =
          await collection.where('recipeId', isEqualTo: recipeId).get();

      if (querySnapshot.docs.isEmpty) {
        print('No documents found for recipeId $recipeId');
      }

      for (var doc in querySnapshot.docs) {
        var existingTimestamp = (doc['date'] as Timestamp).toDate();
        DateTime existingDate = DateTime(existingTimestamp.year,
            existingTimestamp.month, existingTimestamp.day);

        DateTime updatedDateTimeWithExistingDate = DateTime(
          updatedDateTime.year,
          updatedDateTime.month,
          updatedDateTime.day,
          updatedDateTime.hour,
          updatedDateTime.minute,
          updatedDateTime.second,
        );

        Timestamp newTimestamp =
            Timestamp.fromDate(updatedDateTimeWithExistingDate);

        await doc.reference.update({'date': newTimestamp});
      }

      // Call the callback after the update is completed
      callback();
    } catch (e) {
      print('Error updating date for recipeId $recipeId: $e');
    }
  }

  // Function to save selected dates for a recipeId to Firebase
  void saveSelectedDatesToFirebase(
      String recipeId, List<DateTime> selectedDates) async {
    var collection = FirebaseFirestore.instance.collection('selected_dates');
    await collection
        .where('recipeId', isEqualTo: recipeId)
        .get()
        .then((snapshot) {
      // Delete existing documents for the recipeId
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    // Add new selected dates to Firestore
    for (var date in selectedDates) {
      await collection.add({
        'recipeId': recipeId,
        'date': Timestamp.fromDate(date),
        'isCooking': false,
      });
    }
  }

  // Function to check if a recipe is cooking on a specific date
  Future<Map<String, dynamic>> checkIsCooking(
      String recipeId, DateTime date) async {
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);

      var collection = FirebaseFirestore.instance.collection('selected_dates');
      var querySnapshot =
          await collection.where('recipeId', isEqualTo: recipeId).get();

      for (var doc in querySnapshot.docs) {
        var timestamp = (doc['date'] as Timestamp).toDate();
        DateTime docDate =
            DateTime(timestamp.year, timestamp.month, timestamp.day);

        // If the date matches, return the document data
        if (docDate.isAtSameMomentAs(startOfDay)) {
          return doc.data();
        }
      }
      return {};
    } catch (e) {
      print('Error checking isCooking for recipeId $recipeId: $e');
      return {};
    }
  }

  // Function to fetch all selected dates for a recipe that are after today
  Future<List<DateTime>> getSelectedDatesForRecipe(String recipeId) async {
    try {
      DateTime now = DateTime.now();
      var collection = FirebaseFirestore.instance.collection('selected_dates');
      var querySnapshot =
          await collection.where('recipeId', isEqualTo: recipeId).get();

      // Extract dates from the query result
      List<DateTime> selectedDates = querySnapshot.docs
          .map((doc) => (doc['date'] as Timestamp).toDate())
          .where((date) {
        // Exclude dates in the past or today with a time earlier than the current time
        if (date.isBefore(now)) {
          return false; // Exclude dates that are in the past
        }
        return true;
      }).toList();
      print('Selected dates for recipeId $recipeId: $selectedDates');

      return selectedDates;
    } catch (e) {
      print('Error fetching selected dates for recipeId $recipeId: $e');
      return [];
    }
  }

  // Function to fetch selected dates on a specific day and associated recipe data
  Future<List<Map<String, dynamic>>> fetchSelectedDates(Timestamp date) async {
    var collectionDates =
        FirebaseFirestore.instance.collection('selected_dates');
    var collectionRecipes = FirebaseFirestore.instance.collection('Recipe-App');

    DateTime startOfDay =
        DateTime(date.toDate().year, date.toDate().month, date.toDate().day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    // Query to fetch selected dates within the given date range
    var querySnapshot = await collectionDates
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    // Map the query results to a list of selected dates
    List<Map<String, dynamic>> selectedDates =
        querySnapshot.docs.map((doc) => doc.data()).toList();

    List<Map<String, dynamic>> results = [];

    // For each selected date, fetch the associated recipe data
    for (var dateEntry in selectedDates) {
      var recipeId = dateEntry['recipeId'];

      if (recipeId != null) {
        // Fetch the recipe document from the collection
        var recipeDoc = await collectionRecipes.doc(recipeId).get();

        if (recipeDoc.exists) {
          var recipeData = recipeDoc.data();
          if (recipeData != null) {
            // Add the recipe data, along with the document snapshot, to the result list
            results.add({
              'date': dateEntry['date'], // The selected date
              'id': recipeDoc.id, // Recipe ID
              'recipeSnapshot':
                  recipeDoc, // The DocumentSnapshot for the recipe
              ...recipeData, // Spread the recipe data into the map
            });
          }
        }
      }
    }

    return results;
  }

  // Function to remove a specific date for a recipe from Firestore
  void removeDateFromFirebase(DateTime date, String recipeId) async {
    var collection = FirebaseFirestore.instance.collection('selected_dates');
    var timestamp = Timestamp.fromDate(date);
    var querySnapshot = await collection
        .where('recipeId', isEqualTo: recipeId)
        .where('date', isEqualTo: timestamp)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // No matching documents found
    }

    // Delete each document found
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Helper function to access the NotifsProvider within the widget tree
  NotifsProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<NotifsProvider>(
      context,
      listen: listen,
    );
  }
}
