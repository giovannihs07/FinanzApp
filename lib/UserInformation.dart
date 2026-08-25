import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserInformation extends StatefulWidget {
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  late User _user;
  DocumentSnapshot? _userData;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userData = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(_user.uid)
        .get();
    setState(() {
      _userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información del usuario', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.person,
                  size: 110.0,
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 20),
                buildTextField(
                  'Nombre completo',
                  (_userData?['nombres'] ?? '') + ' ' + (_userData?['apellidos'] ?? '') ?? 'Nombre desconocido',
                ),
                const SizedBox(height: 12),
                buildTextField(
                  'Email',
                  _userData?['email']  ?? 'Correo electrónico desconocido',
                ),
                const SizedBox(height: 12),
                buildTextField(
                  'Teléfono',
                  _userData?['telefono'] ?? 'Teléfono desconocido',
                ),
                const SizedBox(height: 12),
                buildTextField(
                  'Edad',
                  _userData?['edad']?.toString() ?? 'Edad desconocida',
                ),
                const SizedBox(height: 12),
                buildTextField(
                  'Cedula',
                  _userData?['cedula']?.toString() ?? 'Cedula desconocida',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String labelText, String value) {
    return TextField(
      enabled: false,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      controller: TextEditingController(text: value),
    );
  }
}
