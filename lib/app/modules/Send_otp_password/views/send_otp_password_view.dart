import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/send_otp_password_controller.dart';

class SendOtpPasswordView extends GetView<SendOtpPasswordController> {
  const SendOtpPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SendOtpPasswordView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'SendOtpPasswordView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
