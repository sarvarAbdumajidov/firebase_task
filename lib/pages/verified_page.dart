import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_task/pages/home_page.dart';
import 'package:flutter/material.dart';

class VerifiedPage extends StatefulWidget {
  static const String id = '/verified';

  const VerifiedPage({super.key});

  @override
  State<VerifiedPage> createState() => _VerifiedPageState();
}

class _VerifiedPageState extends State<VerifiedPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      bool isVerified = await checkEmailVerified();
      if (isVerified) {
        timer.cancel();
        Navigator.pushReplacementNamed(context, HomePage.id);
      }
    });
  }

  Future<bool> checkEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("⚠️ Email hali tasdiqlanmagan!", style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.currentUser?.reload();
                    setState(() {});
                  },
                  child: Text("🔄 Yana tekshirish"),
                ),
              ],
            ),
          ),
        ));
  }
}
