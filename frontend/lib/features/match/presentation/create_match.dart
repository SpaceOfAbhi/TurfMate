import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/colors.dart';
import 'package:frontend/core/widgets/background_img.dart';
import 'package:frontend/features/turf/providers/turf_provider.dart';

import '../../../services/match_service.dart';

class CreateMatchScreen extends ConsumerStatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  ConsumerState<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends ConsumerState<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();

  final sportController = TextEditingController();
  final slotsController = TextEditingController();

  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  final MatchService matchService = MatchService();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedturf_id;
  String? selectedTurfName;
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
    if (selectedTurfName == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select a turf")));

      return;
    }

    final success = await matchService.createMatch(
      sport: sportController.text,

      turf_id: selectedturf_id!,

      turfName: selectedTurfName!,

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
    slotsController.dispose();
    amountController.dispose();
    dateController.dispose();
    timeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final turfs = ref.watch(turfsProvider);
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Create Match"),
          backgroundColor: Colors.transparent,
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),

          child: Form(
            key: _formKey,

            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: sportController,

                    decoration: InputDecoration(
                      labelText: "Sport",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                    ),

                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter sport";
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  turfs.when(
                    data: (data) {
                      final turfList = data.cast<Map<String, dynamic>>();

                      return Autocomplete<Map<String, dynamic>>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return turfList;
                          }

                          return turfList.where((turf) {
                            return turf["name"]
                                .toString()
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },

                        displayStringForOption: (option) =>
                            "${option["name"]} (${option["location_name"]})",

                        onSelected: (option) {
                          setState(() {
                            selectedturf_id = option["id"];

                            selectedTurfName = option["name"];
                          });
                        },

                        fieldViewBuilder:
                            (
                              context,
                              controller,
                              focusNode,
                              onEditingComplete,
                            ) {
                              return TextFormField(
                                controller: controller,
                                focusNode: focusNode,
                                validator: (_) {
                                  if (selectedTurfName == null) {
                                    return "Select a turf";
                                  }

                                  return null;
                                },

                                decoration: InputDecoration(
                                  labelText: "Select Turf",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderColor,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: AppColors.borderColor,
                                      width: 1,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.backgroundColor,
                                ),
                              );
                            },
                      );
                    },

                    loading: () => const CircularProgressIndicator(),

                    error: (_, __) => const Text("Failed to load turfs"),
                  ),

                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dateController,
                    readOnly: true,

                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.calendar_month_rounded),
                      labelText: "Select Date",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
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

                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.access_time_rounded),
                      labelText: "Select Time",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
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

                    decoration: InputDecoration(
                      labelText: "Duration",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                    ),

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

                    decoration: InputDecoration(
                      labelText: "Total Slots",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
                    ),
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

                    decoration: InputDecoration(
                      labelText: "Amount per person",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundColor,
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.borderColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: isLoading ? null : createMatch,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text("Create Match ⚽"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
