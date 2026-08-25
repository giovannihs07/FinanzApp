import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:front_proyecto/PagarCuotaPage.dart';
import 'package:intl/intl.dart';

class CuotasPage extends StatelessWidget {
  final String idCredito;

  CuotasPage({required this.idCredito});

  Future<Map<String, dynamic>> _getCreditoDetails(String idCredito) async {
    DocumentSnapshot creditoSnapshot = await FirebaseFirestore.instance
        .collection('creditos')
        .doc(idCredito)
        .get();

    if (creditoSnapshot.exists) {
      return creditoSnapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception("Crédito no encontrado");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuotas del Crédito', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getCreditoDetails(idCredito),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se encontraron detalles del crédito.'));
          }

          var creditoData = snapshot.data!;
          String titular = creditoData['ClienteId'];
          String descripcion = creditoData['Descripcion'];

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('cuotas')
                .where('IdCredito', isEqualTo: idCredito)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> cuotasSnapshot) {
              if (cuotasSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (cuotasSnapshot.hasError) {
                return Center(child: Text('Error: ${cuotasSnapshot.error}'));
              }
              if (!cuotasSnapshot.hasData || cuotasSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No se encontraron cuotas para este crédito.'));
              }

              return Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DataTable(
                      columnSpacing: 30,
                      columns: const <DataColumn>[
                        DataColumn(
                          label: Text(
                            'Fecha de Pago',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Monto',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Estado',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                        DataColumn(label: SizedBox()),
                      ],
                      rows: cuotasSnapshot.data!.docs.map((cuota) {
                        DateTime fechaPago = (cuota['FechaPago'] as Timestamp).toDate();
                        String fechaPagoFormatted = DateFormat('dd/MM/yyyy').format(fechaPago);

                        return _buildDataRow(
                          fechaPagoFormatted,
                          cuota.id,
                          cuota['MontoCuota'],
                          cuota['Estado'],
                          titular,
                          descripcion,
                          context,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  static DataRow _buildDataRow(
      String fecha, String referencia, double monto, String estado, String titular, String descripcion, BuildContext context) {
    return DataRow(
      color: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return Theme.of(context).colorScheme.primary.withOpacity(0.08);
        }
        return null;
      }),
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey),
              ),
            ),
            child: Text(
              fecha,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataCell(
          Text(
            '\$$monto',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(
          Text(
            estado,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(
          GestureDetector(
            child: Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PagarCuotaPage(
                    cuotaId: referencia,
                    titular: titular,
                    monto: monto,
                    descripcion: descripcion,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
