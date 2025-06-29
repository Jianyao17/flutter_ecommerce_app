import 'package:ecommerce_app/nav_menu.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter E-Commerce App',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.dark(primary: Colors.grey),
        primaryColor: Colors.green
      ),
      home: const NavMenu(),
    );
  }
}

