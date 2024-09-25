import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  const DigitalPetApp({super.key});

  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int energyLevel = 50; // New state variable for energy level
  Color petColor = Colors.yellow;
  Color backgroundColor = Colors.white; // Track background color
  String petMood = "Neutral";
  Timer? hungerTimer;
  Timer? winTimer;
  bool isWinning = false;
  final TextEditingController nameController = TextEditingController();
  String selectedActivity = "Play"; // Default activity selection

  @override
  void initState() {
    super.initState();
    // Start the automatic hunger increase timer
    hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateHunger();
    });
  }

  @override
  void dispose() {
    hungerTimer?.cancel();
    winTimer?.cancel();
    nameController.dispose();
    super.dispose();
  }

  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      energyLevel = (energyLevel - 10).clamp(0, 100);
      _updateHunger();
      _updatePetMood();
      _updatePetColor();
      _checkWinCondition();
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      energyLevel = (energyLevel + 5).clamp(0, 100);
      _updateHappiness();
      _updatePetMood();
      _updatePetColor();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
    _updatePetMood();
    _updatePetColor();
  }

  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel > 100) {
      hungerLevel = 100;
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
    _updatePetMood();
    _updatePetColor();
    _checkWinLossConditions();
  }

  void _updatePetMood() {
    if (happinessLevel > 70) {
      petMood = "Happy";
    } else if (happinessLevel >= 30) {
      petMood = "Neutral";
    } else {
      petMood = "Unhappy";
    }
  }

  void _updatePetColor() {
    if (happinessLevel > 70) {
      petColor = Colors.green;
    } else if (happinessLevel >= 30) {
      petColor = Colors.yellow;
    } else {
      petColor = Colors.red;
    }
  }

  void _checkWinCondition() {
    if (happinessLevel > 80) {
      winTimer ??= Timer(Duration(minutes: 3), () {
        setState(() {
          isWinning = true;
        });
        _showWinDialog();
      });
    } else {
      winTimer?.cancel();
      winTimer = null;
    }
  }

  void _checkWinLossConditions() {
    if (happinessLevel > 80) {
      _checkWinCondition();
    }
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      // Display Game Over message
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Game Over"),
        content: const Text("Your pet is too hungry and unhappy!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("You Win!"),
        content: const Text("Your pet is happy for 3 minutes!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _setPetName() {
    setState(() {
      petName = nameController.text.isNotEmpty ? nameController.text : petName;
      nameController.clear(); // Clear the text field after setting the name
    });
  }

  // New method to switch background color
  void _switchBackgroundColor() {
    setState(() {
      backgroundColor =
          backgroundColor == Colors.white ? Colors.lightBlue : Colors.white;
    });
  }

  // Method to handle activity selection
  void _selectActivity(String? newValue) {
    setState(() {
      selectedActivity = newValue ?? "Play";
    });
  }

  // Method to perform the selected activity
  void _performActivity() {
    setState(() {
      if (selectedActivity == "Play") {
        happinessLevel = (happinessLevel + 10).clamp(0, 100);
        energyLevel = (energyLevel - 10).clamp(0, 100);
      } else if (selectedActivity == "Sleep") {
        energyLevel = (energyLevel + 20).clamp(0, 100);
      } else if (selectedActivity == "Feed") {
        hungerLevel = (hungerLevel - 10).clamp(0, 100);
        energyLevel = (energyLevel + 5).clamp(0, 100);
      }
      _updatePetMood();
      _updatePetColor();
      _checkWinCondition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed:
                _switchBackgroundColor, // Switch background color on button press
          ),
        ],
      ),
      body: Container(
        color: backgroundColor, // Set the background color
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 120, // Adjust the frame size
                height: 120, // Adjust the frame size
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.black, width: 4), // Frame border
                  borderRadius:
                      BorderRadius.circular(10), // Optional: rounded corners
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10), // Match the frame corners
                  child: Image.asset(
                    'img/dog.png', // Use the relative path here
                    fit: BoxFit.cover,
                    color: petColor, // Dynamically change pet color
                    colorBlendMode:
                        BlendMode.color, // Blend mode for color change
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Pet Name: $petName',
                style: const TextStyle(fontSize: 20.0),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Mood: $petMood',
                style: const TextStyle(fontSize: 20.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Happiness Level: $happinessLevel',
                style: const TextStyle(fontSize: 20.0),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Hunger Level: $hungerLevel',
                style: const TextStyle(fontSize: 20.0),
              ),
              const SizedBox(height: 16.0),
              // Energy bar widget
              LinearProgressIndicator(
                value: energyLevel / 100,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: 20,
              ),
              const SizedBox(height: 16.0),
              // Dropdown menu for activity selection
              DropdownButton<String>(
                value: selectedActivity,
                onChanged: _selectActivity,
                items: <String>['Play', 'Sleep', 'Feed']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _performActivity,
                child: const Text('Perform Activity'),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _playWithPet,
                child: const Text('Play with Your Pet'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _feedPet,
                child: const Text('Feed Your Pet'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Enter Pet Name',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: _setPetName,
                child: const Text('Set Pet Name'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
