import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth
import 'package:front_proyecto/globals.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int _age = 18;
  String _selectedRole = 'Cliente';
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    'https://cdn-icons-png.flaticon.com/512/8043/8043680.png',
                    height: 50,
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
                            'Registro',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombres: ',
                              prefixIcon: Icon(Icons.person),
                            ),
                            textAlign: TextAlign.left,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu nombre';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _apellidoController,
                            decoration: const InputDecoration(
                              labelText: 'Apellidos: ',
                              prefixIcon: Icon(Icons.person),
                            ),
                            textAlign: TextAlign.left,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu apellido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _cedulaController,
                            decoration: const InputDecoration(
                              labelText: 'Cédula: ',
                              prefixIcon: Icon(Icons.credit_card),
                            ),
                            textAlign: TextAlign.left,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu cédula';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textAlign: TextAlign.left,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu correo electrónico';
                              }
                              if (!value.contains('@')) {
                                return 'Por favor ingresa un correo electrónico válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _telefonoController,
                            decoration: const InputDecoration(
                              labelText: 'Número de teléfono',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                            textAlign: TextAlign.left,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu número de teléfono';
                              }
                              if (value.length < 10) {
                                return 'Por favor ingresa un número de teléfono válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Edad: $_age'),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (_age > 18) _age--;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    if (_age < 120) _age++;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildDropdownFieldWithIcon(
                              'Rol', Icons.person, ['Cliente', 'Vendedor']),
                          const SizedBox(height: 20),
                          _buildPasswordFieldWithIcon(
                              'Contraseña', Icons.lock, _passwordController, _passwordVisible),
                          const SizedBox(height: 20),
                          _buildPasswordFieldWithIcon('Confirmar Contraseña',
                              Icons.lock, _confirmPasswordController, _confirmPasswordVisible),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _showConfirmationDialog(context);
                              }
                            },
                            child: const Text('Registrarse'),
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
      ),
    );
  }

  Widget _buildDropdownFieldWithIcon(
      String labelText, IconData icon, List<String> options) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
      ),
      value: _selectedRole,
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedRole = newValue!;
          setRol(_selectedRole);
        });
      },
    );
  }

  Widget _buildPasswordFieldWithIcon(
      String labelText, IconData icon, TextEditingController controller, bool isVisible) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              if (labelText == 'Contraseña') {
                _passwordVisible = !_passwordVisible;
              } else {
                _confirmPasswordVisible = !_confirmPasswordVisible;
              }
            });
          },
        ),
      ),
      obscureText: !isVisible,
      textAlign: TextAlign.left,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu $labelText';
        }
        if (labelText == 'Contraseña' && value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }
        if (labelText == 'Confirmar Contraseña' && value != _passwordController.text) {
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    // Verificar si el correo electrónico o la cédula ya están registrados
    FirebaseFirestore.instance
        .collection('usuarios')
        .where('email', isEqualTo: _emailController.text)
        .get()
        .then((QuerySnapshot emailQuerySnapshot) {
      if (emailQuerySnapshot.docs.isNotEmpty) {
        // El correo electrónico ya está registrado
        _showErrorDialog(context, 'Error de registro', 'El correo electrónico ya está registrado.');
      } else {
        FirebaseFirestore.instance
            .collection('usuarios')
            .where('cedula', isEqualTo: _cedulaController.text)
            .get()
            .then((QuerySnapshot cedulaQuerySnapshot) {
          if (cedulaQuerySnapshot.docs.isNotEmpty) {
            // La cédula ya está registrada
            _showErrorDialog(context, 'Error de registro', 'La cédula ya está registrada.');
          } else {
            // Proceder con el registro si ambas validaciones pasan
            _registerUser();
          }
        }).catchError((error) {
          // Manejar errores de la consulta de cédula
          print('Error al consultar Firestore: $error');
        });
      }
    }).catchError((error) {
      // Manejar errores de la consulta de correo electrónico
      print('Error al consultar Firestore: $error');
    });
  }

  void _registerUser() async {
    try {
      // Crear el usuario en Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Guardar la información adicional en Firestore
      _saveUserToFirestore(userCredential.user!.uid);

      // Mostrar diálogo de éxito
      _showSuccessDialog(context);
    } catch (e) {
      // Manejar errores de autenticación
      print('Error al registrar usuario: $e');
      _showErrorDialog(context, 'Error de registro', 'No se pudo registrar el usuario.');
    }
  }

  void _saveUserToFirestore(String uid) {
    CollectionReference users = FirebaseFirestore.instance.collection('usuarios');

    users.doc(uid).set({
      'nombres': _nombreController.text,
      'apellidos': _apellidoController.text,
      'cedula': _cedulaController.text,
      'email': _emailController.text,
      'telefono': _telefonoController.text,
      'edad': _age,
      'rol': _selectedRole,
    }).then((value) {
      print('Usuario agregado correctamente a Firestore');
    }).catchError((error) {
      // Si hay un error al guardar en Firestore, mostrar un mensaje de error
      print("Error al agregar usuario: $error");
      // Puedes agregar aquí un diálogo de error si lo deseas
    });
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registro exitoso'),
          content: const Text('¡Gracias por registrarte!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Cerrar esta pantalla y volver a la de inicio de sesión
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo de error
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
