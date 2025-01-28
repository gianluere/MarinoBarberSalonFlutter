
class NewUser{
  String nome;
  String cognome;
  String email;
  int eta;
  String password;
  String telefono;
  List<dynamic> appuntamenti;

  NewUser(
      {required this.nome,
      required this.cognome,
      required this.email,
      required this.eta,
      required this.password,
      required this.telefono,
      required this.appuntamenti}
      );
}

class UserFirebase{
  String nome;
  String cognome;
  String email;
  int eta;
  String telefono;
  List<dynamic> appuntamenti;

  UserFirebase(
      {required this.nome,
      required this.cognome,
      required this.email,
      required this.eta,
      required this.telefono,
      required this.appuntamenti}
      );
}