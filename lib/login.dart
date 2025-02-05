import 'package:flutter/material.dart';
import 'package:marino_barber_salon_flutter/app_bar.dart';
import 'package:marino_barber_salon_flutter/my_colors.dart';
import 'package:provider/provider.dart';
import 'user_view_model.dart';
import 'my_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";
  bool isPasswordVisible = false;


  @override
  void initState() {
    super.initState();
    checkAuthentication();
  }

  void checkAuthentication() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    if (userViewModel.currentUser != null) {
      // Naviga direttamente alla home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/main');
      });
    }
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }


  @override
  Widget build(BuildContext context) {

    final userViewModel = Provider.of<UserViewModel>(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF333333),
        body: (userViewModel.currentUser != null || userViewModel.isLoading)
            ? const Center(child: CircularProgressIndicator(color: myGold))
            :Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Image.asset(
                        'assets/logo3.png',
                        height: 180.0,
                      ),
                    ),
                    const SizedBox(height: 50.0),

                    // Campo Email
                    TextField(
                      onChanged: (value) => setState(() {
                        email = value;
                      }),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: myWhite),
                        filled: true,
                        fillColor: Colors.transparent,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: myWhite),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: myWhite),
                        )
                      ),
                      style: const TextStyle(color: myWhite),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      cursorColor: myWhite,
                    ),
                    const SizedBox(height: 20.0),

                    // Campo Password
                TextField(
                  onChanged: (value) => setState(() {
                    password = value;
                  }),
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: myWhite),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: myWhite),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: myWhite),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: myWhite),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: myWhite,
                      ),
                      onPressed: togglePasswordVisibility,
                    ),
                  ),
                  cursorColor: myWhite,
                  style: const TextStyle(color: myWhite),
                ),
                    const SizedBox(height: 80.0),

                    // Bottone Accedi
                    ElevatedButton(
                      onPressed: () async {

                        await userViewModel.login(email, password);

                        if (userViewModel.errorMessage != null) {
                          print("Errore");
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Errore"),
                              content: Text(userViewModel.errorMessage!),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        } else {
                          Navigator.pushReplacementNamed(context, '/main');
                          // Naviga alla pagina principale
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: myBordeaux,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 80.0,
                        ),
                      ),
                      child: const Text(
                        "ACCEDI",
                        style: TextStyle(color: myGold, fontSize: 18.0),
                      ),
                    ),
                    SizedBox(height: 20,),
                    TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/sign_up'),
                        child: Text(
                            'Non sei registrato?',
                            style: TextStyle(
                                color: myGold,
                              decoration: TextDecoration.underline,
                              decorationColor: myGold
                            ),
                        )
                    )
                  ],
                ),
              ),
            ),
          ),
      ),
    );
  }
}
