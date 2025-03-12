import 'package:firebase_task/pages/create_page.dart';
import 'package:firebase_task/pages/home_page.dart';
import 'package:firebase_task/pages/signin_page.dart';
import 'package:firebase_task/pages/signup_page.dart';
import 'package:firebase_task/pages/splash_page.dart';
import 'package:firebase_task/pages/verified_page.dart';
import 'package:firebase_task/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('splash_setting');
    String? value = box.get('isEntered');

    value ??= "";
    final isLoggedIn = AuthService.isLoggedIn();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn
          ? HomePage.id
          : (value.isNotEmpty ? SigninPage.id : SplashPage.id),
      routes: {
        SplashPage.id: (context) => SplashPage(),
        HomePage.id: (context) => HomePage(),
        SignupPage.id: (context) => SignupPage(),
        SigninPage.id: (context) => SigninPage(),
        CreatePage.id: (context) => CreatePage(),
        VerifiedPage.id : (context) => VerifiedPage(),
      },
    );
  }
}
