import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CreditsDetailsPage.dart';

class VerDeudasPage extends StatelessWidget {
  final String userCedula;

  VerDeudasPage({required this.userCedula});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deudas Pendientes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16), // Añadir espacio entre el AppBar y el primer elemento
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('creditos')
                    .where('ClienteId', isEqualTo: userCedula)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No se encontraron deudas.'));
                  }
                  return ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final credit = snapshot.data!.docs[index];
                      final description = credit['Descripcion'];
                      final date = (credit['Fecha'] as Timestamp).toDate();
                      // ignore: non_constant_identifier_names
                      final int NroCuotas = credit['Cuotas'];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreditsDetailsPage(creditId: credit.id),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: const Icon(
                              Icons.monetization_on,
                              color: Colors.black,
                            ),
                            title: Text(
                              description,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nro de cuotas del crédito: $NroCuotas'),
                                Text(_formatDateTime(date)),
                              ],)
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 15);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return 'Fecha de creación: ${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
