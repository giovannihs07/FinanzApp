import 'package:flutter/material.dart';

class NotificationDetailPage extends StatelessWidget {
  final String notificationContent;

  NotificationDetailPage({required this.notificationContent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Notificación'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(notificationContent),
        ),
      ),
    );
  }
}
