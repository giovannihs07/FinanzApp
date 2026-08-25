import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class VerDeudasPendientes extends StatefulWidget {
  const VerDeudasPendientes({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VerDeudasPendientesState createState() => _VerDeudasPendientesState();
}

class _VerDeudasPendientesState extends State<VerDeudasPendientes> {
  DateTime? _selectedDate;

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Permitir selección hasta un año en el futuro
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  void _consultarDeudas() {
    if (_selectedDate == null) {
      _showErrorDialog('Por favor seleccione una fecha antes de consultar.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeudasPendientes(fechaSeleccionada: _selectedDate!),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Aceptar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Fecha', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo.shade300,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Seleccione la fecha de la consulta',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.indigo.shade300,
                    ),
                    onPressed: _presentDatePicker,
                    child: const Text('Seleccionar Fecha'),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _selectedDate == null
                       ? 'Fecha seleccionada: No ha seleccionado fecha'
                        : 'Fecha seleccionada: ${DateFormat.yMd().format(_selectedDate!)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.indigo.shade300,
                    ),
                    onPressed: _consultarDeudas,
                    child: const Text('Consultar'),
                  ),
                ],
              )
              
            ) 
          ),
        ),
      ),
    );
  }
}

class DeudasPendientes extends StatelessWidget {
  final DateTime fechaSeleccionada;

  const DeudasPendientes({super.key, required this.fechaSeleccionada});

  Future<List<Map<String, dynamic>>> _getDeudasPendientes(DateTime fechaSeleccionada) async {
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
      QuerySnapshot creditosSnapshot = await FirebaseFirestore.instance
          .collection('creditos')
          .where('VendedorId', isEqualTo: vendedorCedula)
          .get();

      List<Map<String, dynamic>> deudasPendientes = [];

      for (var credito in creditosSnapshot.docs) {
        String clienteCedula = credito['ClienteId'];
        String descripcion = credito['Descripcion'];

        QuerySnapshot cuotasSnapshot = await FirebaseFirestore.instance
            .collection('cuotas')
            .where('IdCredito', isEqualTo: credito.id)
            .where('FechaPago', isLessThanOrEqualTo: fechaSeleccionada)
            .where('Estado', isEqualTo: 'Pendiente')
            .get();

        if (cuotasSnapshot.docs.isNotEmpty) {
          QuerySnapshot clienteSnapshot = await FirebaseFirestore.instance
              .collection('usuarios')
              .where('cedula', isEqualTo: clienteCedula)
              .get();

          if (clienteSnapshot.docs.isNotEmpty) {
            var clienteData = clienteSnapshot.docs.first.data() as Map<String, dynamic>?;
            if (clienteData != null) {
              var clienteNombre = '${clienteData['nombres']} ${clienteData['apellidos']}';

              deudasPendientes.add({
                'clienteNombre': clienteNombre,
                'descripcion': descripcion,
                'cuotasPendientes': cuotasSnapshot.docs.length,
                'creditoId': credito.id,
              });
            }
          }
        }
      }

      return deudasPendientes;
    } else {
      throw Exception('Usuario no autenticado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deudas Pendientes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo.shade300,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getDeudasPendientes(fechaSeleccionada),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final deudas = snapshot.data!;
            return ListView.builder(
              itemCount: deudas.length,
              itemBuilder: (context, index) {
                var deuda = deudas[index];
                return Card(
                  color: Colors.indigo.shade50,
                  elevation: 5,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(deuda['descripcion'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Titular: ${deuda['clienteNombre']}'),
                    trailing: Text('Cuotas restantes: ${deuda['cuotasPendientes']}'),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No hay deudas pendientes para la fecha seleccionada.'));
          }
        },
      ),
    );
  }
}
