import 'dart:async';

import 'package:firebase_task/pages/home_page.dart';
import 'package:firebase_task/pages/signin_page.dart';
import 'package:firebase_task/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SplashPage extends StatefulWidget {
  static const String id = '/splash';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _box = Hive.box('splash_setting');

  _timer() async {
    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;

      Navigator.pushReplacementNamed(context, SigninPage.id);

  }

  _saveData() {
    _box.put('isEntered', 'true');
    _timer();
  }

  @override
  void initState() {
    super.initState();
    _saveData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          alignment: Alignment(0, -0.4),
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1a2a6c),
                Color(0xFFb21f1f),
                Color(0xFFfdbb2d),
              ],
            ),
          ),
          child: Text(
            'Welcome',
            style: TextStyle(
              color: Colors.white,
              fontSize: 50,
            ),
          ),
        ),
      ),
    );
  }
}
