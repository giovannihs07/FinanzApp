import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Estadisticas extends StatelessWidget {
  const Estadisticas({super.key});

  Future<Map<String, dynamic>> _getEstadisticas() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot vendedorSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (!vendedorSnapshot.exists) {
        throw Exception('Vendedor no encontrado');
      }

      String vendedorCedula = vendedorSnapshot['cedula'];

      // Número de clientes actuales
      QuerySnapshot clientesSnapshot = await FirebaseFirestore.instance
      .collection('creditos')
      .where('VendedorId', isEqualTo: vendedorCedula)
      .get();

      // Crear un conjunto para almacenar los IDs de clientes únicos
      Set<String> clientesIds = {};

      // Iterar sobre los documentos para recoger los IDs de clientes únicos
      clientesSnapshot.docs.forEach((doc) {
        String clienteId = doc['ClienteId'];
        clientesIds.add(clienteId);
      });

      // Obtener el número de clientes únicos
      int numeroClientesActuales = clientesIds.length;
      
      // Monto total pendiente (todos los créditos)
      QuerySnapshot creditosSnapshot = await FirebaseFirestore.instance
          .collection('creditos')
          .where('VendedorId', isEqualTo: vendedorCedula)
          .get();

      double montoTotalPendiente = 0.0;
      double totalPrestado = 0.0;
      int numeroClientesSaldados = 0;

      for (var credito in creditosSnapshot.docs) {
        double montoCredito = credito['Monto'];
        totalPrestado += montoCredito;

        QuerySnapshot cuotasSnapshot = await FirebaseFirestore.instance
            .collection('cuotas')
            .where('IdCredito', isEqualTo: credito.id)
            .where('Estado', isEqualTo: 'Pendiente')
            .get();

        if (cuotasSnapshot.docs.isEmpty) {
          numeroClientesSaldados++;
        } else {
          for (var cuota in cuotasSnapshot.docs) {
            montoTotalPendiente += cuota['MontoCuota'];
          }
        }
      }

      // Total ingresos programados (del mes actual)
      DateTime now = DateTime.now();
      DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
      DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

      QuerySnapshot ingresosSnapshot = await FirebaseFirestore.instance
          .collection('cuotas')
          .where('IdCredito', whereIn: creditosSnapshot.docs.map((doc) => doc.id).toList())
          .where('FechaPago', isGreaterThanOrEqualTo: firstDayOfMonth)
          .where('FechaPago', isLessThanOrEqualTo: lastDayOfMonth)
          .where('Estado', isEqualTo: 'Pendiente')
          .get();

      double totalIngresosProgramados = 0.0;
      for (var ingreso in ingresosSnapshot.docs) {
        totalIngresosProgramados += ingreso['MontoCuota'];
      }

      return {
        'numeroClientesActuales': numeroClientesActuales,
        'montoTotalPendiente': montoTotalPendiente,
        'totalPrestado': totalPrestado,
        'numeroClientesSaldados': numeroClientesSaldados,
        'totalIngresosProgramados': totalIngresosProgramados,
      };
    } else {
      throw Exception('Usuario no autenticado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información Financiera', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo.shade300,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getEstadisticas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var data = snapshot.data!;
            return Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.account_balance_wallet,
                      size: 70.0,
                      color: Colors.indigo.shade300,
                    ),
                    const SizedBox(height: 20),
                    buildTextField('Número de clientes actuales', data['numeroClientesActuales'].toString()),
                    const SizedBox(height: 10),
                    buildTextField('Monto total pendiente', data['montoTotalPendiente'].toStringAsFixed(2)),
                    const SizedBox(height: 10),
                    buildTextField('Total prestado en créditos', data['totalPrestado'].toStringAsFixed(2)),
                    const SizedBox(height: 10),
                    buildTextField('Número de clientes saldados', data['numeroClientesSaldados'].toString()),
                    const SizedBox(height: 10),
                    buildTextField('Total ingresos programados', data['totalIngresosProgramados'].toStringAsFixed(2)),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No se encontraron datos.'));
          }
        },
      ),
    );
  }

  Widget buildTextField(String labelText, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              labelText,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Container(
            width: 150,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.indigo.shade300),
            ),
          ),
        ],
      ),
    );
  }
}