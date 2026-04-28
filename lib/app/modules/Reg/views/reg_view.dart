import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/reg_controller.dart';

class RegView extends GetView<RegController> {
  const RegView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RegView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'RegView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
