import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AgregarCredito extends StatefulWidget {
  const AgregarCredito({super.key});

  @override
  _AgregarCreditoState createState() => _AgregarCreditoState();
}

class _AgregarCreditoState extends State<AgregarCredito> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _idController = TextEditingController();
  final _creditoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _fechaLimiteController = TextEditingController();
  int _cuotas = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Crédito a Cliente'), foregroundColor: Colors.white,
        backgroundColor: Colors.indigo.shade300,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre del Cliente',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese el nombre del cliente';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _idController,
                          decoration: const InputDecoration(
                            labelText: 'ID del Cliente',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.fingerprint),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese el ID del cliente';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _creditoController,
                          decoration: const InputDecoration(
                            labelText: 'Cantidad de Crédito',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese la cantidad de crédito';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _descripcionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción del Crédito',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese la descripción del crédito';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _fechaLimiteController,
                          decoration: const InputDecoration(
                            labelText: 'Fecha Límite (dd/MM/yyyy)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese la fecha límite';
                            }
                            return null;
                          },
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2101),
                            );
        
                            if (pickedDate != null) {
                              setState(() {
                                _fechaLimiteController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Número de Cuotas: $_cuotas'),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (_cuotas > 1) _cuotas--;
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  _cuotas++;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.indigo.shade300,
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _agregarCredito();
                              }
                            },
                            child: const Text('Registrar Crédito'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ),
      ),
    );
  }

  void _agregarCredito() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog(context, 'Error', 'Usuario no autenticado.');
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        _showErrorDialog(context, 'Error', 'Datos del vendedor no encontrados.');
        return;
      }

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      String vendedorCedula = userData?['cedula'];
      String clienteId = _idController.text;

      QuerySnapshot clienteQuery = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('cedula', isEqualTo: clienteId)
          .where('rol', isEqualTo: 'Cliente')
          .get();

      if (clienteQuery.docs.isEmpty) {
        _showErrorDialog(context, 'Error', 'ID de cliente no válido o el cliente no tiene el rol adecuado.');
        return;
      }

      DocumentReference docRef = FirebaseFirestore.instance.collection('creditos').doc();
      DateTime fechaLimite = DateFormat('dd/MM/yyyy').parse(_fechaLimiteController.text);

      await docRef.set({
        'IdCredito': docRef.id,
        'VendedorId': vendedorCedula,
        'ClienteId': clienteId,
        'Monto': double.parse(_creditoController.text),
        'Cuotas': _cuotas,
        'Descripcion': _descripcionController.text,
        'Fecha': Timestamp.now(),
        'FechaLimite': Timestamp.fromDate(fechaLimite),
      });

      double montoCuota = double.parse(_creditoController.text) / _cuotas;
      DateTime fechaInicio = DateTime.now();

      for (int i = 0; i < _cuotas; i++) {
        DateTime fechaPago = fechaInicio.add(Duration(
            days: (fechaLimite.difference(fechaInicio).inDays / _cuotas).round() * (i + 1)));

        await FirebaseFirestore.instance.collection('cuotas').add({
          'IdCredito': docRef.id,
          'MontoCuota': montoCuota,
          'Estado': 'Pendiente',
          'FechaPago': Timestamp.fromDate(fechaPago),
        });
      }

      _showConfirmationDialog(context);
    } catch (e) {
      _showErrorDialog(context, 'Error al registrar el crédito', e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación de Registro\n'),
          content: const Text('¡Operación exitosa!.'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
