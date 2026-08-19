import 'package:flutter/material.dart';
import 'package:planpal/domain/enums/filter_tab.dart';

/// Tasks screen — full implementation in Wave 6.
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key, this.initialFilter});
  final FilterTab? initialFilter;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Tasks')),
    );
  }
}
