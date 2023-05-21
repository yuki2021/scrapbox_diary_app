import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DatePickerState extends StateNotifier<DateTime> {
  DatePickerState() : super(DateTime.now());

  Future<void> pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: state,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ja', 'JP'),
    );
    if (pickedDate != null && pickedDate != state) {
      state = pickedDate;
    }
  }
}
