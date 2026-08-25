import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:front_proyecto/CuotasPage.dart';
import 'package:intl/intl.dart';

class AbonarPagoPage extends StatelessWidget {
  const AbonarPagoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créditos del Cliente', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _getClienteCedula(),
        builder: (context, AsyncSnapshot<String?> clienteCedulaSnapshot) {
          if (clienteCedulaSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (clienteCedulaSnapshot.hasError) {
            return Center(child: Text('Error: ${clienteCedulaSnapshot.error}'));
          }
          if (!clienteCedulaSnapshot.hasData) {
            return const Center(child: Text('No se pudo obtener el ID del cliente.'));
          }

          String? clienteCedula = clienteCedulaSnapshot.data;
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('creditos')
                .where('ClienteId', isEqualTo: clienteCedula)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No se encontraron créditos para este cliente.'));
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Seleccione el crédito a abonar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Times New Roman'
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final credito = snapshot.data!.docs[index];
                          return _buildCreditCard(
                            credito,
                            context,
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 10);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String?> _getClienteCedula() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    return userDoc['cedula'] as String?;
  }

  Widget _buildCreditCard(DocumentSnapshot credito, BuildContext context) {
    double monto = credito['Monto'];
    DateTime fechaLimite = credito['FechaLimite'].toDate();
    String descripcion = credito['Descripcion'];
    int cuotas = credito['Cuotas'];
    String idCredito = credito.id; // Obtener el IdCredito

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CuotasPage(idCredito: idCredito),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueGrey),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: const Icon(
            Icons.monetization_on,
            color: Colors.black,
            size: 30,
          ),
          title: Text(
            '\$$monto',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fecha Límite: ${DateFormat('dd/MM/yyyy').format(fechaLimite)}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Descripción: $descripcion',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Nro Cuotas: $cuotas',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
