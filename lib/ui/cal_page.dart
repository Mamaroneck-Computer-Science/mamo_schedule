import 'package:flutter/material.dart';
import '../data/calendar.dart';
import 'package:clock/clock.dart';

class CalPage extends StatefulWidget {
  @override
  _CalPageState createState() => _CalPageState();
}

class _CalPageState extends State<CalPage> {
  DateTime? _selectedDate;
  String _dayType = '';
  bool _loading = false;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? clock.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _loading = true;
      _dayType = '';
    });

    // TODO: replace with actual getDayType call, e.g.:
    final result = await getDayType('MHS', picked);
    setState(() {
      _dayType = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Day Type Lookup',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: Text(
              _selectedDate == null
                  ? 'Pick a date'
                  : '${_selectedDate!.year}-'
                      '${_selectedDate!.month.toString().padLeft(2, '0')}-'
                      '${_selectedDate!.day.toString().padLeft(2, '0')}',
            ),
          ),
          const SizedBox(height: 32),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_selectedDate != null)
            Column(
              children: [
                Text(
                  'Schedule day:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _dayType.isEmpty ? '(no result)' : _dayType,
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
