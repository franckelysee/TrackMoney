import 'package:flutter/material.dart';
import 'package:trackmoney/templates/header.dart';


class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppHeader(title: 'Notification')),
      body: Center(
        child: Text('Notification'),
      ),
    );
  }
}