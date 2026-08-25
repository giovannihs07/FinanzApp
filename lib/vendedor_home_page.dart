import 'package:flutter/material.dart';

class VendedorHomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  VendedorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('FinanzApp'),
        centerTitle: true,
        foregroundColor: Colors.indigo.shade300,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30), // Icono de usuario
            onPressed: () {
              // Mostrar menú de usuario
              _scaffoldKey.currentState!.openEndDrawer(); // Abre el drawer desde la derecha
            },
          ),
        ],
      ),
      endDrawer: Drawer( // Cambia de drawer a endDrawer para abrirlo desde la derecha
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo.shade300,
              ),
              child: const Center(
                child: Text(
                  'Menú de Usuario',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                     fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.indigo.shade300),
              title: Text('Perfil', style: TextStyle(color: Colors.indigo.shade300, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/info_user');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.indigo.shade300),
              title: Text('Cerrar Sesión', style: TextStyle(color: Colors.indigo.shade300, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: <Widget>[
             DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo.shade300,
              ),
              child: const Center(
                child: Text(
                  'Menú principal',
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
              leading: Icon(Icons.account_balance_wallet_rounded, color: Colors.indigo.shade300),
              title: Text('Agregar Crédito', style: TextStyle(color: Colors.indigo.shade300, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/agregar_credito');
              },
            ),
            ListTile(
              leading: Icon(Icons.search_rounded, color: Colors.indigo.shade300),
              title: Text('Consultar Cliente', style: TextStyle(color: Colors.indigo.shade300, fontWeight: FontWeight.bold)),
              onTap: () {
              Navigator.pushNamed(context, '/consultar_cliente');
              },
            ),
            ListTile(
              leading: Icon(Icons.remove_red_eye_sharp, color: Colors.indigo.shade300),
              title: Text('Ver deudas pendientes', style: TextStyle(color: Colors.indigo.shade300, fontWeight: FontWeight.bold)),
              onTap: () {
              Navigator.pushNamed(context, '/pendientes');
              },
            ),
            ListTile(
              leading: Icon(Icons.data_thresholding_sharp, color: Colors.indigo.shade300),
              title: Text('Estadísticas del mes', style: TextStyle(color: Colors.indigo.shade300, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pushNamed(context, '/estadisticas');
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
              height: 100,
            ),
            const Text(
              'FinanzApp',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent
              ),
            ),
            const SizedBox(height: 100), // Espacio entre la imagen y el texto
            const Text(
              '"Tu App de confianza"',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
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