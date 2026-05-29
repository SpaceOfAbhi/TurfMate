import 'package:flutter/material.dart';

import '../../../services/match_service.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() =>
      _CreateMatchScreenState();
}

class _CreateMatchScreenState
    extends State<CreateMatchScreen> {

  final _formKey =
      GlobalKey<FormState>();

  final sportController =
      TextEditingController();

  final turfController =
      TextEditingController();

  final slotsController =
      TextEditingController();

  final amountController =
      TextEditingController();

  final MatchService matchService =
      MatchService();

  bool isLoading = false;

  Future<void> createMatch() async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final success =
        await matchService.createMatch(
      sport: sportController.text,
      turfName: turfController.text,
      totalSlots: int.parse(
        slotsController.text,
      ),
      amountPerPerson: double.parse(
        amountController.text,
      ),
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Match Created",
          ),
        ),
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Failed to create match",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {

    sportController.dispose();
    turfController.dispose();
    slotsController.dispose();
    amountController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
            const Text("Create Match"),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(16),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              TextFormField(
                controller:
                    sportController,

                decoration:
                    const InputDecoration(
                  labelText: "Sport",
                ),

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return "Enter sport";
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    turfController,

                decoration:
                    const InputDecoration(
                  labelText: "Turf Name",
                ),

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return "Enter turf name";
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    slotsController,

                keyboardType:
                    TextInputType.number,

                decoration:
                    const InputDecoration(
                  labelText:
                      "Total Slots",
                ),

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return "Enter slots";
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 16,
              ),

              TextFormField(
                controller:
                    amountController,

                keyboardType:
                    TextInputType.number,

                decoration:
                    const InputDecoration(
                  labelText:
                      "Amount Per Person",
                ),

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return "Enter amount";
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 24,
              ),

              SizedBox(

                width:
                    double.infinity,

                child:
                    ElevatedButton(

                  onPressed:
                      isLoading
                          ? null
                          : createMatch,

                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Create Match",
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}