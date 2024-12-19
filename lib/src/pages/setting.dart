import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lord_bible/src/controller/scale_controller.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    final TextScaleController textScaleController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Setting')),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Adjust Text Size:',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Obx(() => CupertinoSlider(
            value: textScaleController.textScale.value,
            min: 0.5,
            max: 1.5,
            divisions: 15,
            onChanged: textScaleController.updateTextScale,
          )),
          Obx(() => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Current Scale: ${textScaleController.textScale.value.toStringAsFixed(2)}x',
              style: const TextStyle(fontSize: 16),
            ),
          )),
        ],
      ),
    );
  }
}
