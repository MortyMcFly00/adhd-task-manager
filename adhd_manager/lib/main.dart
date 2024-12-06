// ADHD Task Management App in Flutter (Reflected Update with Timer)

import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(ADHDManagerApp());
}

class ADHDManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ADHD Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TaskManagerScreen(),
    );
  }
}

class TaskManagerScreen extends StatefulWidget {
  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  final Map<String, List<Map<String, dynamic>>> tasksByInterval = {
    'Daily': [],
    'Weekly': [],
    'Monthly': [],
    'Annual': [],
    'Overdue': [],
  };
  String selectedInterval = 'Daily';

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        checkOverdueTasks();
      });
    });
  }

  void checkOverdueTasks() {
    DateTime now = DateTime.now();
    tasksByInterval.forEach((interval, tasks) {
      if (interval != 'Overdue') {
        tasks.removeWhere((task) {
          if (task['dueDate'].isBefore(now)) {
            tasksByInterval['Overdue']!.add(task);
            return true;
          }
          return false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          DropdownButton<String>(
            value: selectedInterval,
            items: ['Daily', 'Weekly', 'Monthly', 'Annual', 'Overdue']
                .map((interval) => DropdownMenuItem(
              value: interval,
              child: Text(interval),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedInterval = value!;
              });
            },
          ),
        ],
      ),
      body: selectedInterval == 'Overdue'
          ? tasksByInterval['Overdue']!.isEmpty
          ? Center(child: Text('No overdue tasks!'))
          : ListView.builder(
        itemCount: tasksByInterval['Overdue']!.length,
        itemBuilder: (context, index) {
          final task = tasksByInterval['Overdue']![index];
          return ListTile(
            title: Text(task['title']),
            subtitle: Text('Priority: ${task['priority']}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: () {
                    setState(() {
                      task['completed'] = true;
                      tasksByInterval['Overdue']!.removeAt(index);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      tasksByInterval['Overdue']!.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        },
      )
          : tasksByInterval[selectedInterval]!.isEmpty
          ? Center(child: Text('No tasks for $selectedInterval! Add a task to get started.'))
          : ListView.builder(
        itemCount: tasksByInterval[selectedInterval]!.length,
        itemBuilder: (context, index) {
          final task = tasksByInterval[selectedInterval]![index];
          return ListTile(
            title: Text(task['title']),
            subtitle: Text('Priority: ${task['priority']}'),
            trailing: Checkbox(
              value: task['completed'],
              onChanged: (value) {
                setState(() {
                  task['completed'] = value!;
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addTask(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddTaskScreen(
        onAdd: (task, interval) {
          setState(() {
            tasksByInterval[interval]!.add(task);
          });
        },
      )),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  final Function(Map<String, dynamic>, String) onAdd;

  AddTaskScreen({required this.onAdd});

  final TextEditingController titleController = TextEditingController();
  String priority = 'Low';
  String interval = 'Daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            DropdownButton<String>(
              value: priority,
              items: ['Low', 'Medium', 'High']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                priority = value!;
              },
            ),
            DropdownButton<String>(
              value: interval,
              items: ['Daily', 'Weekly', 'Monthly', 'Annual']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                interval = value!;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                onAdd({
                  'title': titleController.text,
                  'priority': priority,
                  'completed': false,
                  'dueDate': DateTime.now().add(Duration(days: 1)), //Example due date
                }, interval);
                Navigator.pop(context);
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}