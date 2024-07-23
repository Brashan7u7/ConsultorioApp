import 'package:calendario_manik/models/paciente.dart';
import 'package:flutter/material.dart';
import 'package:calendario_manik/database/database.dart';
import 'package:calendario_manik/pages/patients_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PacienteContent extends StatefulWidget {
  final int? usuario_id;
  const PacienteContent({super.key, this.usuario_id});
  @override
  _PacienteContentState createState() => _PacienteContentState();
}

class _PacienteContentState extends State<PacienteContent> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController apPaternoController = TextEditingController();
  TextEditingController apMaternoController = TextEditingController();
  TextEditingController fechaNacimientoController = TextEditingController();
  TextEditingController sexoController = TextEditingController();
  TextEditingController coloniaIdController = TextEditingController();
  TextEditingController telefonoMovilController = TextEditingController();
  TextEditingController telefonoFijoController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController avatarController = TextEditingController();
  TextEditingController fechaRegistroController = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  TextEditingController identificadorController = TextEditingController();
  TextEditingController curpController = TextEditingController();
  TextEditingController codigoPostalController = TextEditingController();
  TextEditingController municipioIdController = TextEditingController();
  TextEditingController estadoIdController = TextEditingController();
  TextEditingController paisController = TextEditingController();
  TextEditingController paisIdController = TextEditingController();
  TextEditingController entidadNacimientoIdController = TextEditingController();
  TextEditingController generoIdController = TextEditingController();

  String selectedSexo = 'M';

  Future<void> fetchLocationData(String postalCode) async {
    final response = await http.get(Uri.parse(
        'https://api.copomex.com/query/info_cp/$postalCode?token=a7a13953-8c5f-46c1-9f43-dafdb1160303'));

    if (response.statusCode == 200) {
      final List<dynamic> dataList = json.decode(response.body);
      if (dataList.isNotEmpty) {
        final Map<String, dynamic> data = dataList.first['response'];
        setState(() {
          municipioIdController.text = data['municipio'];
          estadoIdController.text = data['estado'];
          paisIdController.text = 'México';
        });
      } else {
        print(
            'Error: No se encontraron datos de ubicación para el código postal proporcionado.');
      }
    } else {
      print(
          'Error al obtener los datos de la ubicación. Código de estado: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Ingrese el nombre del paciente',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                )),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre del paciente es obligatorio';
                  }
                  return null;
                },
              ),

              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Ingrese el apellido paterno',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              TextFormField(
                controller: apPaternoController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                )),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Ingrese el apellido materno',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              TextFormField(
                controller: apMaternoController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                )),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Seleccione su fecha de nacimiento',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              TextFormField(
                controller: fechaNacimientoController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 1, color: Colors.grey),
                  ),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2101),
                    //locale: Locale('es', 'ES'),
                  );
                  if (pickedDate != null) {
                    String formattedDate =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                    setState(() {
                      fechaNacimientoController.text = formattedDate;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La fecha de nacimiento es obligatoria';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Seleccione su sexo',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              DropdownButtonFormField<String>(
                items: const [
                  DropdownMenuItem<String>(
                    value: 'M',
                    child: Text('Masculino'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'F',
                    child: Text('Femenino'),
                  ),
                ],
                value: selectedSexo,
                onChanged: (value) {
                  setState(() {
                    selectedSexo = value!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(width: 1, color: Colors.grey),
                  ),
                ),
              ),
              // TextFormField(
              //   controller: coloniaIdController,
              //   decoration: InputDecoration(labelText: 'ColoniaId'),
              // ),

              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Ingrese su curp',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              TextFormField(
                controller: curpController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                )),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El CURP es obligatorio';
                  }

                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Ingrese su telefono movil',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              TextFormField(
                controller: telefonoMovilController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(width: 1, color: Colors.grey),
                )),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingresa el teléfono';
                  } else if (value.length < 7) {
                    return 'El teléfono debe tener al menos 7 dígitos';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Ingrese su Telefono fijo',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              TextFormField(
                controller: telefonoFijoController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(width: 1, color: Colors.grey),
                )),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingresa el teléfono';
                  } else if (value.length < 7) {
                    return 'El teléfono debe tener al menos 7 dígitos';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Ingrese su Correo eléctronico',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              TextFormField(
                controller: correoController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(width: 1, color: Colors.grey),
                )),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo electrónico es obligatorio';
                  }
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!regex.hasMatch(value)) {
                    return 'Ingresa un correo electrónico válido';
                  }
                  return null;
                },
              ),
              // TextFormField(
              //   controller: avatarController,
              //   decoration: InputDecoration(labelText: 'Avatar'),
              // ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Ingrese su Direccion',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              TextFormField(
                controller: direccionController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(width: 1, color: Colors.grey),
                )),
              ),
              // TextFormField(
              //   controller: identificadorController,
              //   decoration: InputDecoration(labelText: 'Identificador'),
              // ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  'Ingrese su codigo postal',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey[800]),
                ),
              ),
              TextFormField(
                controller: codigoPostalController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(width: 1, color: Colors.grey),
                )),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  if (value.length == 5) {
                    fetchLocationData(value);
                  }
                },
              ),
              // TextFormField(
              //   controller: municipioIdController,
              //   decoration: InputDecoration(labelText: 'Municipio'),
              // ),
              // TextFormField(
              //   controller: estadoIdController,
              //   decoration: InputDecoration(labelText: 'Estado'),
              // ),
              // TextFormField(
              //   controller: paisIdController,
              //   decoration: InputDecoration(labelText: 'País'),
              // ),
              // TextFormField(
              //   controller: entidadNacimientoIdController,
              //   decoration:
              //       InputDecoration(labelText: 'ID Entidad de Nacimiento'),
              // ),
              // TextFormField(
              //   controller: generoIdController,
              //   decoration: InputDecoration(labelText: 'ID Género'),
              // ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss')
                          .format(DateTime.now());
                      fechaRegistroController.text = formattedDate;
                      await DatabaseManager.insertPaciente(
                        Paciente(
                          nombre: nameController.text,
                          apPaterno: apPaternoController.text,
                          apMaterno: apMaternoController.text,
                          fechaNacimiento: fechaNacimientoController.text,
                          sexo: selectedSexo,
                          //coloniaId: int.parse(coloniaIdController.text),
                          telefonoMovil: telefonoMovilController.text,
                          telefonoFijo: telefonoFijoController.text,
                          correo: correoController.text,
                          // avatar: avatarController.text,
                          fechaRegistro:
                              DateTime.parse(fechaRegistroController.text),
                          direccion: direccionController.text,
                          //identificador: identificadorController.text,
                          curp: curpController.text,
                          codigoPostal: int.parse(codigoPostalController.text),
                          // municipioId: int.parse(municipioIdController.text),
                          // estadoId: int.parse(estadoIdController.text),
                          // pais: paisController.text,
                          // paisId: int.parse(paisIdController.text),
                          // entidadNacimientoId:
                          //     entidadNacimientoIdController.text,
                          // generoId: int.parse(generoIdController.text),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Paciente guardado con éxito')),
                      );
                      await Future.delayed(const Duration(milliseconds: 1500));

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Patients(usuario_id: widget.usuario_id)),
                      );
                    } catch (e) {
                      print('Error al insertar el paciente: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Error al guardar el paciente')),
                      );
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
