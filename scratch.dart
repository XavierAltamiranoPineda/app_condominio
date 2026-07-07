import 'package:app_condominio/features/residentes/models/residente.dart';
import 'dart:convert';

void main() {
  final res = Residente(
    id: '1',
    nombre: 'Juan',
    apellido: 'Perez',
    email: 'juan@email.com',
    telefono: '0999999999',
    activo: true,
    cedula: '1234567890',
    createdAt: DateTime.now(),
  );
  print(jsonEncode(res.toJson()));
}
