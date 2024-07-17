class DataPatients {
  int id;
  String name;
  String sexo;
  String primerPat;
  String segundPat;
  String fechaNaci;
  String correo;
  String telefonomov;
  String telefonofij;
  String direccion;
  String curp;
  int codigoPostal;

  DataPatients({
    required this.id,
    required this.name,
    required this.sexo,
    required this.primerPat,
    required this.segundPat,
    required this.fechaNaci,
    required this.correo,
    required this.telefonomov,
    required this.telefonofij,
    required this.direccion,
    required this.curp,
    required this.codigoPostal,
  });

  @override
  String toString() {
    return 'DataPatients{id: $id, name: $name, sexo: $sexo, curp: $curp, primerPat: $primerPat, segundPat: $segundPat, fechaNaci: $fechaNaci, correo: $correo, telefonomov: $telefonomov, telefonofij: $telefonofij, direccion: $direccion, codigoPostal: $codigoPostal}';
  }
}
