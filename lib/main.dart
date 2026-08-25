import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:front_proyecto/AbonarPagoPage.dart';
import 'package:front_proyecto/AgregarCredito.dart';
import 'package:front_proyecto/Cliente_home_page.dart';
import 'package:front_proyecto/ConsultarCliente.dart';
import 'package:front_proyecto/CuotasPage.dart';
import 'package:front_proyecto/Estadisticas.dart';
import 'package:front_proyecto/Pendientes.dart';
import 'package:front_proyecto/UserInformation.dart';
import 'package:front_proyecto/LoginPage.dart';
import 'package:front_proyecto/PagarCuotaPage.dart';
import 'package:front_proyecto/RegisterPage.dart';
import 'package:front_proyecto/VerDeudasPage.dart';
import 'package:front_proyecto/NotificacionesPage.dart';
import 'vendedor_home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Limpiar la caché de Firestore
  await FirebaseFirestore.instance.clearPersistence();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinanzApp',
      debugShowCheckedModeBanner: false, // Oculta la viñeta "DEBUG"
      theme: ThemeData(
        useMaterial3: true,
        //primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorSchemeSeed: Colors.blueGrey
      ),
      initialRoute: '/', // Ruta inicial
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterPage());
          case '/cliente_home':
            return MaterialPageRoute(builder: (context) => ClienteHomePage());
          case '/vendedor_home':
            return MaterialPageRoute(builder: (context) => VendedorHomePage());
          case '/abonar_pago':
            return MaterialPageRoute(builder: (context) => const AbonarPagoPage());
          case '/cuotas':
            if (settings.arguments is String) {
              final idCredito = settings.arguments as String;
              return MaterialPageRoute(
                builder: (context) => CuotasPage(idCredito: idCredito),
              );
            }
            return _errorRoute();
          case '/pagarCuota': (context) => (settings) {
            final args = settings.arguments as Map<String, dynamic>;
            return PagarCuotaPage(
              cuotaId: args['cuotaId'],
              titular: args['titular'],
              monto: args['monto'],
              descripcion: args['descripcion'],
            );
          };
          case '/notificaciones':
            return MaterialPageRoute(builder: (context) => NotificationsPage());
          case '/verDeudas':
            return MaterialPageRoute(
              builder: (context) => FutureBuilder<DocumentSnapshot>(
                future: _getCurrentUserCedula(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                    return const Scaffold(
                      body: Center(child: Text('Error al obtener datos del usuario')),
                    );
                  }
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  return VerDeudasPage(userCedula: userData['cedula']);
                },
              ),
            );
          case '/agregar_credito':
            return MaterialPageRoute(builder: (context) => const AgregarCredito());
          case '/consultar_cliente':
            return MaterialPageRoute(builder: (context) => const ConsultarCliente());
          case '/pendientes':
            return MaterialPageRoute(builder: (context) => const VerDeudasPendientes());
          case '/info_user':
            return MaterialPageRoute(builder: (context) => UserInformation());
            case '/estadisticas':
            return MaterialPageRoute(builder: (context) => const Estadisticas());
          default:
            return _errorRoute();
        }
        return null;
      },
    );
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
          ),
          body: const Center(
            child: Text('Página no encontrada'),
          ),
        );
      },
    );
  }


  Future<DocumentSnapshot> _getCurrentUserCedula() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No hay usuario autenticado');
    }
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    if (!userSnapshot.exists) {
      throw Exception('Usuario no encontrado');
    }
    return userSnapshot;
  }
}
