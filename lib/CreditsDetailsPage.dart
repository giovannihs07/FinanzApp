import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreditsDetailsPage extends StatelessWidget {
  final String creditId;

  const CreditsDetailsPage({super.key, required this.creditId});

  Future<Map<String, dynamic>> _fetchCreditDetails() async {
    try {
      // Fetch credit details
      DocumentSnapshot creditSnapshot = await FirebaseFirestore.instance.collection('creditos').doc(creditId).get();
      if (!creditSnapshot.exists) {
        throw Exception("Credit not found");
      }
      var creditData = creditSnapshot.data() as Map<String, dynamic>;

      // Fetch vendedor details
      String vendedorCedula = creditData['VendedorId'];
      QuerySnapshot vendedorQuery = await FirebaseFirestore.instance.collection('usuarios').where('cedula', isEqualTo: vendedorCedula).get();
      if (vendedorQuery.docs.isEmpty) {
        throw Exception("Vendedor not found");
      }
      var vendedorData = vendedorQuery.docs.first.data() as Map<String, dynamic>;

      // Fetch cuotas
      QuerySnapshot cuotasSnapshot = await FirebaseFirestore.instance.collection('cuotas').where('IdCredito', isEqualTo: creditId).get();
      int cuotasPendientes = cuotasSnapshot.docs.where((doc) => doc['Estado'] == 'Pendiente').length;
      double montoRestante = cuotasSnapshot.docs.where((doc) => doc['Estado'] == 'Pendiente').fold(0.0, (sum, doc) => sum + doc['MontoCuota']);

      return {
        'creditData': creditData,
        'vendedorData': vendedorData,
        'cuotasPendientes': cuotasPendientes,
        'montoRestante': montoRestante,
      };
    } catch (e) {
      throw Exception("Failed to fetch credit details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Crédito', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchCreditDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontraron detalles.'));
          }

          var creditData = snapshot.data!['creditData'];
          var vendedorData = snapshot.data!['vendedorData'];
          int cuotasPendientes = snapshot.data!['cuotasPendientes'];
          double montoRestante = snapshot.data!['montoRestante'];

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: SingleChildScrollView(
                    child: Column(
                      
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Descripción: ${creditData['Descripcion'] ?? 'N/A'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text('Referencia: $creditId', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Text('Nombre del Vendedor: ${vendedorData['nombres'] ?? 'N/A'} ${vendedorData['apellidos'] ?? 'N/A'}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Text('Cuotas pendientes: $cuotasPendientes', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Text('Monto restante por pagar: \$${montoRestante.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Text('Fecha límite: ${_formatDateTime((creditData['FechaLimite'] as Timestamp?)?.toDate())}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Regresar a la ventana anterior
                          },
                          child: const Text('Confirmar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'N/A';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
