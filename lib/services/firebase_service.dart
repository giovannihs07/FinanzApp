
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore BaseDatos = FirebaseFirestore.instance;

Future<List> getUsuario() async{
  List listaUsuarios = [];

  CollectionReference collectionReferenceClientes = BaseDatos.collection('Clientes');
  QuerySnapshot queryCliente = await collectionReferenceClientes.get();

  queryCliente.docs.forEach((element) {
    print(element.data());
    listaUsuarios.add(element.data()); 
  });

    print(listaUsuarios);
  
  return listaUsuarios;
}

