import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:introchat/presentation/chat/chatscreen.dart';
import 'package:introchat/presentation/register/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? seen = prefs.getString('username');
  runApp(ProviderScope(
      child: MyApp(
    username: seen,
  )));
}

class MyApp extends StatelessWidget {
  final String? username;
  const MyApp({super.key, required this.username});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'intro chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.

        primarySwatch: Colors.teal,
        //scaffoldBackgroundColor: const Color(0xff151B20),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
        inputDecorationTheme: const InputDecorationTheme(
          hintStyle: TextStyle(color: Colors.black54),
          labelStyle: TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(
              5,
            )),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(
              5,
            )),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(
              5,
            )),
          ),
        ),
      ),
      initialRoute: username == null ? RegisterScreen.id : ChatScreen.id,
      routes: {
        RegisterScreen.id: (context) => const RegisterScreen(),
        ChatScreen.id: (context) => const ChatScreen(),
      },
    );
  }
}
