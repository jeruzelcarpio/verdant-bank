import 'package:flutter/material.dart';

void main() {
  runApp(SavingsApp());
}

class SavingsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF031D16), // Dark green background
      ),
      home: SavingsScreen(),
    );
  }
}

class SavingsScreen extends StatefulWidget {
  @override
  _SavingsScreenState createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  List<Map<String, dynamic>> savings = [];

  void addSaving(String title, double goal, int total) {
    setState(() {
      savings.add({"title": title, "goal": goal, "total": total});
    });
  }

  void showAddSavingDialog() {
    final titleController = TextEditingController();
    final goalController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF043927), // Dark green
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ADD NEW SAVING",
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF025E47),
                  labelText: "Name of Saving",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: goalController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF025E47),
                  labelText: "Goal Amount",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFB6E2D3),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  final title = titleController.text;
                  final goal = double.tryParse(goalController.text) ?? 0;
                  if (title.isNotEmpty && goal > 0) {
                    addSaving(title, goal, (goal * 10000).toInt());
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  "Add",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SAVINGS",
          style: TextStyle(
            color: Colors.green[300],
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            color: Colors.green[300],
            onPressed: () {
              // Show Reminder Dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Color(0xFF0B4430), // Dark green
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "REMINDER",
                          style: TextStyle(
                            color: Color(0xFFFABF36), // Yellow
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "1. Once a ‘Saving’ is created, it can only be deleted if and only if it has no money inside it.\n\n"
                              "2. After moving money into the ‘Saving’, the only way to retrieve the money is to reach the goal of the savings.\n\n"
                              "3. Think carefully before putting money inside the savings to avoid any mistakes.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFFFABF36), // Yellow button
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: Text(
                          "OK",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.70,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF0B4430), // Dark green container
                borderRadius: BorderRadius.circular(20),
              ),
              child: savings.isEmpty
                  ? Center(
                child: Text(
                  "No Savings Added",
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: savings.length,
                itemBuilder: (context, index) {
                  final item = savings[index];
                  return ListTile(
                    title: Text(
                      item["title"],
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Goal: ${(item["goal"] * 100).toInt()}%",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                },
              ),
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA7E571),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 104),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: showAddSavingDialog,
                  child: Text(
                    "Add New Saving",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA7E571),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 115),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    // Implement select saving functionality
                  },
                  child: Text(
                    "Select Saving",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



