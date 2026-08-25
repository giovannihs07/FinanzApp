import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PagarCuotaPage extends StatefulWidget {
  final String cuotaId;
  final String titular;
  final double monto;
  final String descripcion;

  const PagarCuotaPage({super.key, 
    required this.cuotaId,
    required this.titular,
    required this.monto,
    required this.descripcion,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PagarCuotaPageState createState() => _PagarCuotaPageState();
}

class _PagarCuotaPageState extends State<PagarCuotaPage> {
  String _selectedBank = 'Bancolombia';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey, // Establecer el color de fondo del AppBar
        centerTitle: true, // Centrar el título del AppBar
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.payment,
                  size: 50,
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Pago',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        _buildReadOnlyField('Identificación del Titular:', widget.titular),
                        const SizedBox(height: 20),
                        _buildReadOnlyField('Cantidad:', '\$${widget.monto.toString()}'),
                        const SizedBox(height: 20),
                        _buildReadOnlyField('Descripción:', widget.descripcion),
                        const SizedBox(height: 20),
                        _buildBankSelection(),
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Número de cuenta',
                            prefixIcon: Icon(Icons.account_balance),
                          ),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            _showConfirmationDialog(context);
                          },
                          child: const Text('Pagar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.account_balance),
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildBankSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Banco:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.account_balance, color: Colors.blueGrey),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: _selectedBank,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBank = newValue!;
                });
              },
              items: <String>['Bancolombia', 'Davivienda']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación de pago'),
          content: Text(
              'Detalles del pago:\n\nIdentificación del Titular: ${widget.titular}\nCantidad: \$${widget.monto}\nDescripción: ${widget.descripcion}\nBanco: $_selectedBank\nNúmero de cuenta: [Número de cuenta ingresado]\n\n¿Desea continuar con el pago?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Actualizar el estado de la cuota en Firestore
                await FirebaseFirestore.instance
                    .collection('cuotas')
                    .doc(widget.cuotaId)
                    .update({'Estado': 'Pagada'});

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Pago realizado con éxito!'),
                    duration: Duration(seconds: 3),
                  ),
                );
                Navigator.pop(context); // Volver a la página anterior
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }
}
