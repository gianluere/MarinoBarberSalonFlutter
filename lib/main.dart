import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:marino_barber_salon_flutter/Account/lista_recensioni_view_model.dart';
import 'package:marino_barber_salon_flutter/Home/lista_giorni_view_model.dart';
import 'package:marino_barber_salon_flutter/Home/lista_servizi_view_model.dart';
import 'package:marino_barber_salon_flutter/Home/notifiche_view_model.dart';
import 'package:marino_barber_salon_flutter/Shop/lista_prodotti_view_model.dart';
import 'package:marino_barber_salon_flutter/main_wrapper.dart';
import 'package:marino_barber_salon_flutter/sign_up.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:marino_barber_salon_flutter/login.dart';
import 'user_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized(); // Assicura che i binding di Flutter siano inizializzati prima di eseguire codice asincrono.

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Inizializza Firebase con le opzioni corrette per la piattaforma.
  );

  await initializeDateFormatting('it_IT', null);

  await Supabase.initialize(
    url: 'https://dboogadeyqtgiirwnopm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRib29nYWRleXF0Z2lpcndub3BtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY0NTMyMDQsImV4cCI6MjA1MjAyOTIwNH0.5AERHBZ3WTKr9KOzTNQRWp-xCgNserTU1j1dyJTpIMY',
  );

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
        ChangeNotifierProvider(create: (_) => NotificheViewModel()),
        ChangeNotifierProvider(create: (_) => ListaServiziViewModel()),
        ChangeNotifierProvider(create: (_) => ListaGiorniViewModel()),
        ChangeNotifierProvider(create: (_) => ListaRecensioniViewModel()),
        ChangeNotifierProvider(create: (_) => ListaProdottiViewModel())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Marino Barber Salon',
        navigatorKey: mainNavigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/sign_up': (context) => SignUpScreen(),
          '/main' : (context) => MainWrapper(),
        }
      ),
    );
  }
}

