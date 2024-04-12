import 'package:flutter/material.dart';

class Patients extends StatefulWidget {
  final DataPatients? newPatient;

  Patients({Key? key, this.newPatient}) : super(key: key);

  @override
  State<Patients> createState() => _PatientsState();
}

class _PatientsState extends State<Patients> {
  List<DataPatients> _allPatients = [
    DataPatients(
        id: "1",
        name: "Manuel",
        lastname: "García",
        phone: "+52 951 123 4567",
        symptoms: "Dolor de cabeza",
        materno: "Dolores",
        birthDate: "20/02/2003",
        mobilePhone: "951359520",
        email: "Manueell2@gmail.com",
        landline: "5862413"),
    DataPatients(
        id: "2",
        name: "Luisa",
        lastname: "Martínez",
        phone: "+52 951 987 6543",
        symptoms: "Fiebre alta",
        materno: "Flores",
        birthDate: "15/05/1998",
        mobilePhone: "951753159",
        email: "luisamartinez@example.com",
        landline: "9876543"),
    DataPatients(
        id: "3",
        name: "Juan",
        lastname: "Gómez",
        phone: "+52 951 555 1234",
        symptoms: "Dolor de garganta",
        materno: "Sánchez",
        birthDate: "10/10/1990",
        mobilePhone: "951357159",
        email: "juangomez@example.com",
        landline: "5551234"),
    DataPatients(
        id: "4",
        name: "María",
        lastname: "López",
        phone: "+52 951 789 0123",
        symptoms: "Dolor abdominal",
        materno: "Hernández",
        birthDate: "05/07/1985",
        mobilePhone: "951852963",
        email: "marialopez@example.com",
        landline: "7890123"),
    DataPatients(
        id: "5",
        name: "Carlos",
        lastname: "Hernández",
        phone: "+52 951 321 9876",
        symptoms: "Tos persistente",
        materno: "Gómez",
        birthDate: "25/12/1978",
        mobilePhone: "951753951",
        email: "carloshernandez@example.com",
        landline: "3219876"),
    DataPatients(
        id: "6",
        name: "Ana",
        lastname: "Sánchez",
        phone: "+52 951 456 7890",
        symptoms: "Fatiga extrema",
        materno: "Martínez",
        birthDate: "03/04/1965",
        mobilePhone: "951369852",
        email: "anasanchez@example.com",
        landline: "4567890"),
    DataPatients(
        id: "7",
        name: "Pedro",
        lastname: "Díaz",
        phone: "+52 951 888 8888",
        symptoms: "Congestión nasal",
        materno: "Pérez",
        birthDate: "18/09/1980",
        mobilePhone: "951951951",
        email: "pedrodiaz@example.com",
        landline: "8888888"),
    DataPatients(
        id: "8",
        name: "Laura",
        lastname: "Ramírez",
        phone: "+52 951 777 7777",
        symptoms: "Dificultad para respirar",
        materno: "Luna",
        birthDate: "21/11/1973",
        mobilePhone: "951753951",
        email: "lauraramirez@example.com",
        landline: "7777777"),
    DataPatients(
        id: "9",
        name: "Sofía",
        lastname: "Gutiérrez",
        phone: "+52 951 666 6666",
        symptoms: "Dolor en el pecho",
        materno: "Díaz",
        birthDate: "14/02/1988",
        mobilePhone: "951369951",
        email: "sofiagutierrez@example.com",
        landline: "6666666"),
    DataPatients(
        id: "10",
        name: "Miguel",
        lastname: "Pérez",
        phone: "+52 951 999 9999",
        symptoms: "Escalofríos",
        materno: "Sánchez",
        birthDate: "30/06/1976",
        mobilePhone: "951852753",
        email: "miguelperez@example.com",
        landline: "9999999"),
    DataPatients(
        id: "11",
        name: "Alejandra",
        lastname: "Flores",
        phone: "+52 951 000 0000",
        symptoms: "Náuseas y vómitos",
        materno: "García",
        birthDate: "08/03/1992",
        mobilePhone: "951753852",
        email: "alejandraflores@example.com",
        landline: "0000000"),
    DataPatients(
        id: "12",
        name: "Fernando",
        lastname: "Cruz",
        phone: "+52 951 111 1111",
        symptoms: "Dolor articular",
        materno: "López",
        birthDate: "17/07/1983",
        mobilePhone: "951852147",
        email: "fernandocruz@example.com",
        landline: "1111111"),
    DataPatients(
        id: "13",
        name: "Paola",
        lastname: "Torres",
        phone: "+52 951 222 2222",
        symptoms: "Malestar general",
        materno: "Martínez",
        birthDate: "12/05/1970",
        mobilePhone: "951753456",
        email: "paolatorres@example.com",
        landline: "2222222"),
    DataPatients(
        id: "14",
        name: "Eduardo",
        lastname: "Castillo",
        phone: "+52 951 333 3333",
        symptoms: "Urticaria",
        materno: "Sánchez",
        birthDate: "29/11/1986",
        mobilePhone: "951456123",
        email: "eduardocastillo@example.com",
        landline: "3333333"),
    DataPatients(
        id: "15",
        name: "Gabriela",
        lastname: "Luna",
        phone: "+52 951 444 4444",
        symptoms: "Dolor lumbar",
        materno: "Hernández",
        birthDate: "04/09/1995",
        mobilePhone: "951789456",
        email: "gabrielaluna@example.com",
        landline: "4444444")
  ];

  late ScrollController _scrollController;
  List<DataPatients> _displayedPatients = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _loadInitialPatients();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePatients();
    }
  }

  _loadInitialPatients() {
    setState(() {
      _displayedPatients.addAll(_allPatients.take(10));
    });
  }

  _loadMorePatients() {
    setState(() {
      _displayedPatients
          .addAll(_allPatients.skip(_displayedPatients.length).take(10));
    });
  }

  _onSearchChanged() {
    String searchText = _searchController.text.toLowerCase();
    if (searchText.length >= 3) {
      setState(() {
        _displayedPatients = _allPatients
            .where((patient) {
              String fullName =
                  "${patient.name} ${patient.lastname}".toLowerCase();
              return fullName.contains(searchText);
            })
            .toList()
            .take(10)
            .toList();
      });
    } else {
      setState(() {
        _displayedPatients.clear();
        _displayedPatients.addAll(_allPatients.take(10));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar Paciente',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Icon(Icons.search),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _displayedPatients.length + 1,
              itemBuilder: (context, index) {
                if (index == _displayedPatients.length) {
                  return _buildLoadMoreIndicator();
                } else {
                  return _buildPatientTile(_displayedPatients[index]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildPatientTile(DataPatients patient) {
    return ListTile(
      onTap: () {
        _viewPatient(context, patient);
      },
      title: Text("${patient.name} ${patient.lastname}"),
      subtitle: Text(patient.phone),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_forward_ios),
            onPressed: () {
              _viewPatient(context, patient);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deletePatient(patient);
            },
          ),
        ],
      ),
    );
  }

  void _viewPatient(BuildContext context, DataPatients patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Datos de ${patient.name}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DataTable(
                headingRowHeight: 40,
                dataRowHeight: 40,
                columns: [
                  DataColumn(
                    label: Text(
                      'Campo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Valor',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: [
                  _buildDataRow('Identificador', patient.id),
                  _buildDataRow('Nombre', patient.name),
                  _buildDataRow('Apellido paterno', patient.lastname),
                  _buildDataRow('Apellido materno', patient.materno ?? ''),
                  _buildDataRow('Fecha de nacimiento', patient.birthDate ?? ''),
                  _buildDataRow('Teléfono móvil', patient.mobilePhone ?? ''),
                  _buildDataRow('Correo electrónico', patient.email ?? ''),
                  _buildDataRow('Teléfono fijo', patient.landline ?? ''),
                  _buildDataRow('Síntomas', patient.symptoms ?? ''),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(String label, String value) {
    return DataRow(cells: [
      DataCell(
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      DataCell(
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(value),
        ),
      ),
    ]);
  }

  _deletePatient(DataPatients patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Eliminar Paciente"),
          content: Text(
              "¿Estás seguro de que quieres eliminar a ${patient.name} ${patient.lastname}?"),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _allPatients.remove(patient);
                  _displayedPatients.remove(patient);
                });
                Navigator.pop(context);
              },
              child: const Text('Sí'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }
}

class DataPatients {
  String id;
  String name;
  String lastname;
  String phone;
  String symptoms;
  String materno;
  String birthDate;
  String mobilePhone;
  String email;
  String landline;
  DataPatients(
      {required this.id,
      required this.name,
      required this.lastname,
      required this.phone,
      required this.symptoms,
      required this.materno,
      required this.birthDate,
      required this.mobilePhone,
      required this.email,
      required this.landline});
}
