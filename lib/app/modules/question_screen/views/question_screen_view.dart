import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/question_screen_controller.dart';

class QuestionScreenView extends GetView<QuestionScreenController> {
  const QuestionScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuestionScreenView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'QuestionScreenView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
