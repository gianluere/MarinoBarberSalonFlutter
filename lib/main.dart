import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:marino_barber_salon_flutter/Home/lista_giorni_view_model.dart';
import 'package:marino_barber_salon_flutter/Home/lista_servizi_view_model.dart';
import 'package:marino_barber_salon_flutter/main_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:marino_barber_salon_flutter/login.dart';
import 'user_view_model.dart';
import 'Home/home.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized(); // Assicura che i binding di Flutter siano inizializzati prima di eseguire codice asincrono.

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Inizializza Firebase con le opzioni corrette per la piattaforma.
  );

  await initializeDateFormatting('it_IT', null);

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> mainNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => ListaServiziViewModel()),
        ChangeNotifierProvider(create: (_) => ListaGiorniViewModel())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Marino Barber Salon',
        navigatorKey: mainNavigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/main' : (context) => MainWrapper()
        }
      ),
    );
  }
}

