import 'package:flutter/material.dart';
import 'package:front_proyecto/NotificationDetailsPage.dart'; // Importa la ventana de detalle de notificación

class PaymentNotification {
  final IconData icon;
  final String description;
  final String content; // Contenido de la notificación
  final DateTime dateTime;

  PaymentNotification({
    required this.icon,
    required this.description,
    required this.content,
    required this.dateTime,
  });
}

class NotificationsPage extends StatelessWidget {
  final List<PaymentNotification> notifications = [
    PaymentNotification(
      icon: Icons.payment,
      description: 'Pago de cuota aprobado',
      content: 'El pago de tu cuota ha sido aprobado.',
      dateTime: DateTime.now(),
    ),
    PaymentNotification(
      icon: Icons.warning,
      description: 'Pago de cuota atrasado',
      content: 'Tu cuota está atrasada. Por favor, realiza el pago lo antes posible.',
      dateTime: DateTime.now().subtract(Duration(hours: 1)),
    ),
    PaymentNotification(
      icon: Icons.check_circle,
      description: 'Cuota pagada exitosamente',
      content: 'Has realizado el pago de tu cuota exitosamente.',
      dateTime: DateTime.now().subtract(Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey, // Establecer el color de fondo del AppBar
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // Agrega un padding alrededor de la lista
        child: ListView.separated(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationDetailPage(notificationContent: notification.content),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Icon(
                    notification.icon,
                    color: Colors.black,
                  ),
                  title: Text(
                    notification.description,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_formatDateTime(notification.dateTime)),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(height: 10);
          },
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}
