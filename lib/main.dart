import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:projectx/screens/main_screen.dart';
import 'package:projectx/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(
    MyApp(
      token: prefs.getString('token'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final dynamic token;
  const MyApp({required this.token, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: (token == null)
          ? const LoginScreen()
          : ((JwtDecoder.isExpired(token) == false)
              ? MainScreen(token: token)
              : const LoginScreen()),
      // home: ((JwtDecoder.isExpired(token) == false)
      //     ? MainScreen(token: token)
      //     : const LoginScreen()),
      routes: {
        'register': (context) => const RegisterScreen(),
        'login': (context) => const LoginScreen(),
      },
    );
  }
}
