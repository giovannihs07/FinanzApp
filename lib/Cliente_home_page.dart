import 'package:flutter/material.dart';

class ClienteHomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ClienteHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('FinanzApp'),
        centerTitle: true,
        foregroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            iconSize: 40,
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              _scaffoldKey.currentState!.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Center(
                child: Text(
                'Menú de Usuario',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Roboto', // Cambia la fuente del texto
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.blueGrey), // Icono para "Perfil"
              title: const Text('Perfil', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/info_user');
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.blueGrey), // Icono para "Cerrar Sesión"
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/');// Acción al presionar "Cerrar Sesión"
              },
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centra horizontalmente
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Center(
                child: Text(
                  'FinanzApp',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.blueGrey),
              title: const Text('Abonar Pago', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/abonar_pago');// Acción al presionar "Abonar Pago"
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: Colors.blueGrey),
              title: const Text('Consultar Cuotas Restantes', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/verDeudas');// Acción al presionar "Consultar Cuotas Restantes"
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: Colors.blueGrey),
              title: const Text('Notificaciones', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/notificaciones');
              },
            ),
            const Expanded(
              child: SizedBox(),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blueGrey),
              title: const Text('About Us', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              onTap: () {
                // Acción al presionar "About Us"
              },
            ),
          ],
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/Logo 5.png',
              width: 100,
              height: 100
            ),
            const Text(
              'FinanzApp',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blue
              ),
            ),
            const SizedBox(height: 100), // Espacio entre la imagen y el texto
            const Text(
              '"Tu App de confianza"',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontFamily: 'Dancing Script',
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
