class Paciente {
  String nombre;
  String apPaterno;
  String apMaterno;
  String fechaNacimiento;
  String sexo;
  //int coloniaId;
  //int coloniaId;
  String telefonoMovil;
  String telefonoFijo;
  String correo;
  //String avatar;
  DateTime fechaRegistro;
  String direccion;
  //String identificador;
  String curp;
  int codigoPostal;
  String municipioId;
  String estadoId;
  String pais;
  // int paisId;
  // String entidadNacimientoId;
  // int generoId;
  int consultorioId;

  Paciente({
    required this.nombre,
    required this.apPaterno,
    required this.apMaterno,
    required this.fechaNacimiento,
    required this.sexo,
    //required this.coloniaId,
    //required this.coloniaId,
    required this.telefonoMovil,
    required this.telefonoFijo,
    required this.correo,
    // required this.avatar,
    required this.fechaRegistro,
    required this.direccion,
    //required this.identificador,
    required this.curp,
    required this.codigoPostal,
    required this.municipioId,
    required this.estadoId,
    required this.pais,
    // required this.paisId,
    // required this.entidadNacimientoId,
    // required this.generoId,
    required this.consultorioId,
  });
}
