import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConsultarCliente extends StatelessWidget {
  const ConsultarCliente({super.key});

  Future<List<Map<String, dynamic>>> _getClientesDelVendedor() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Paso 1: Obtener la cédula del vendedor usando el UID
      DocumentSnapshot vendedorSnapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (!vendedorSnapshot.exists) {
        throw Exception('Vendedor no encontrado');
      }

      String vendedorCedula = vendedorSnapshot['cedula'];
      print('Cédula del vendedor: $vendedorCedula'); // Imprimir la cédula del vendedor

      // Paso 2: Utilizar la cédula para buscar en la colección creditos
      QuerySnapshot creditosSnapshot = await FirebaseFirestore.instance
          .collection('creditos')
          .where('VendedorId', isEqualTo: vendedorCedula)
          .get();

      List<String> clientesIds = [];

      for (QueryDocumentSnapshot creditoSnapshot in creditosSnapshot.docs) {
        String clienteId = creditoSnapshot['ClienteId'];
        clientesIds.add(clienteId);
      }

      if (clientesIds.isNotEmpty) {
        QuerySnapshot usuariosSnapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('cedula', whereIn: clientesIds)
            .get();

        List<Map<String, dynamic>> clientesConEstado = [];

        for (var clienteSnapshot in usuariosSnapshot.docs) {
          var clienteData = clienteSnapshot.data() as Map<String, dynamic>;
          clienteData['cedula'] = clienteSnapshot['cedula']; // Ajuste aquí para obtener la cédula correcta
          clienteData['id'] = clienteSnapshot.id; // Adjuntar documentId

          // Obtener créditos del cliente
          QuerySnapshot creditosClienteSnapshot = await FirebaseFirestore.instance
              .collection('creditos')
              .where('ClienteId', isEqualTo: clienteSnapshot['cedula'])
              .get();

          bool pendiente = false;

          for (var credito in creditosClienteSnapshot.docs) {
            // Obtener cuotas del crédito
            QuerySnapshot cuotasSnapshot = await FirebaseFirestore.instance
                .collection('cuotas')
                .where('CreditoId', isEqualTo: credito.id)
                .get();

            for (var cuota in cuotasSnapshot.docs) {
              if (cuota['estado'] == 'pendiente') {
                pendiente = true;
                break;
              }
            }
            if (pendiente) break;
          }

          clienteData['estado'] = pendiente ? 'Pagado' : 'Pendiente';
          clientesConEstado.add(clienteData);
        }
        return clientesConEstado;
      } else {
        print('No hay clientes asociados con este vendedor.');
        return []; // No hay clientes asociados con este vendedor
      }
    } else {
      throw Exception('Usuario no autenticado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo.shade300,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getClientesDelVendedor(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final clientes = snapshot.data!;
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
                          'Cliente N°',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Nombre',
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
                    rows: clientes.asMap().entries.map((entry) {
                      int index = entry.key;
                      var cliente = entry.value;
                      return _buildDataRow(index + 1, cliente, context);
                    }).toList(),
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('No hay clientes disponibles.'));
          }
        },
      ),
    );
  }

  static DataRow _buildDataRow(int numero, Map<String, dynamic> cliente, BuildContext context) {
    return DataRow(
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
              numero.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        DataCell(
          Text(
            '${cliente['nombres']} ${cliente['apellidos']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(
          Text(
            cliente['estado'] ?? 'N/A',
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
                  builder: (context) => DetallesCliente(clienteId: cliente['id']), // Usar el documentId
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class DetallesCliente extends StatelessWidget {
  final String clienteId;

  const DetallesCliente({Key? key, required this.clienteId}) : super(key: key);

  Future<Map<String, dynamic>> _getClienteDetalles() async {
    // Obtener detalles básicos del cliente
    DocumentSnapshot clienteSnapshot =
        await FirebaseFirestore.instance.collection('usuarios').doc(clienteId).get();

    if (!clienteSnapshot.exists) {
      throw Exception('Cliente no encontrado');
    }

    Map<String, dynamic> clienteData = clienteSnapshot.data() as Map<String, dynamic>;

    // Obtener créditos del cliente
    QuerySnapshot creditosSnapshot = await FirebaseFirestore.instance
        .collection('creditos')
        .where('ClienteId', isEqualTo: clienteData['cedula'])
        .get();
    
    

    int totalCreditos = creditosSnapshot.docs.length;
    double montoTotalCreditos = 0;
    int totalCuotas = 0;
    int cuotasPagadas = 0;
    double montoTotalPagado = 0;

    print(clienteData);

    for (var credito in creditosSnapshot.docs) {
      double montoCredito = credito['Monto'];
      int numeroDeCuotas = credito['Cuotas'];
      montoTotalCreditos += montoCredito;
      totalCuotas += numeroDeCuotas;

      QuerySnapshot cuotasSnapshot = await FirebaseFirestore.instance
          .collection('cuotas')
          .where('IdCredito', isEqualTo: credito.id)
          .get();

      for (var cuota in cuotasSnapshot.docs) {
        if (cuota['Estado'] == 'Pagada') {
          cuotasPagadas++;
          montoTotalPagado += cuota['MontoCuota'];
        }
      }
    }

    clienteData['totalCreditos'] = totalCreditos;
    clienteData['montoTotalCreditos'] = montoTotalCreditos;
    clienteData['totalCuotas'] = totalCuotas;
    clienteData['cuotasPagadas'] = cuotasPagadas;
    clienteData['montoTotalPagado'] = montoTotalPagado;

    return clienteData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Cliente', style: TextStyle(color: Colors.white)),
        backgroundColor:Colors.indigo.shade300,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getClienteDetalles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos.'));
          } else if (snapshot.hasData) {
            var cliente = snapshot.data!;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // Para que el card se ajuste al contenido
                      children: [
                        const Text(
                          'Información personal', 
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 10),
                        Text('Nombre: ${cliente['nombres']} ${cliente['apellidos']}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Cédula: ${cliente['cedula']}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Edad: ${cliente['edad']}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Email: ${cliente['email']}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Teléfono: ${cliente['telefono']}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 30),
                        const Text(
                          'Información financiera', 
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 10),
                        Text('Total de Créditos: ${cliente['totalCreditos']}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Monto Total de Créditos: \$${cliente['montoTotalCreditos'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Total de Cuotas: ${cliente['totalCuotas']}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Cuotas Pagadas: ${cliente['cuotasPagadas']}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text('Monto Total Pagado: \$${cliente['montoTotalPagado'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.indigo.shade300,
                            ),
                            onPressed: () {
                              Navigator.pop(context); // Regresar a la ventana anterior
                            },
                            child: const Text('Aceptar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: Text('Cliente no encontrado.'));
          }
        },
      ),
    );
  }
}
