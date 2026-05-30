import 'package:flutter/material.dart';

import '../../../services/match_service.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();

  final sportController = TextEditingController();

  final turfController = TextEditingController();

  final slotsController = TextEditingController();

  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  final MatchService matchService = MatchService();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final durations = [60, 90, 120];

  int selectedDuration = 60;
  bool isLoading = false;

  Future<void> createMatch() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a date")));

      return;
    }

    if (selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a time")));

      return;
    }

    setState(() {
      isLoading = true;
    });

    final startTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final endTime = startTime.add(Duration(minutes: selectedDuration));

    final success = await matchService.createMatch(
      sport: sportController.text,

      turfName: turfController.text,

      startTime: startTime.toIso8601String(),

      endTime: endTime.toIso8601String(),

      totalSlots: int.parse(slotsController.text),

      amountPerPerson: double.parse(amountController.text),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Match Created")));

      sportController.clear();
      turfController.clear();
      slotsController.clear();
      amountController.clear();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to create match")));
    }
  }

  @override
  void dispose() {
    sportController.dispose();
    turfController.dispose();
    slotsController.dispose();
    amountController.dispose();
    dateController.dispose();
    timeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Match")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              TextFormField(
                controller: sportController,

                decoration: const InputDecoration(labelText: "Sport"),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter sport";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: turfController,

                decoration: const InputDecoration(labelText: "Turf Name"),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter turf name";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),
              TextFormField(
                controller: dateController,
                readOnly: true,

                decoration: const InputDecoration(
                  //  labelText: "Match Date",
                  hintText: "Select Match Date",
                  prefixIcon: Icon(Icons.calendar_today),
                ),

                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 60)),
                    initialDate: DateTime.now(),
                  );

                  if (date != null) {
                    selectedDate = date;

                    dateController.text =
                        "${date.day}/${date.month}/${date.year}";
                  }
                },

                validator: (_) {
                  if (selectedDate == null) {
                    return "Select a date";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: timeController,
                readOnly: true,

                decoration: const InputDecoration(
                  labelText: "Start Time",
                  prefixIcon: Icon(Icons.access_time),
                ),

                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (time != null) {
                    selectedTime = time;

                    timeController.text = time.format(context);
                  }
                },

                validator: (_) {
                  if (selectedTime == null) {
                    return "Select a time";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: selectedDuration,

                decoration: const InputDecoration(labelText: "Duration"),

                items: const [
                  DropdownMenuItem(value: 60, child: Text("1 Hour")),

                  DropdownMenuItem(value: 90, child: Text("1.5 Hours")),

                  DropdownMenuItem(value: 120, child: Text("2 Hours")),
                ],

                onChanged: (value) {
                  setState(() {
                    selectedDuration = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: slotsController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(labelText: "Total Slots"),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter slots";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: amountController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: "Amount Per Person",
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter amount";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: isLoading ? null : createMatch,

                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Create Match"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
