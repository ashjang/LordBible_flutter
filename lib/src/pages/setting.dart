import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lord_bible/src/controller/scale_controller.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final TextScaleController textScaleController = Get.find();

  @override
  Widget build(BuildContext context) {
    final TextScaleController textScaleController = Get.find();

    return Scaffold(
      appBar: CupertinoNavigationBar(
        heroTag: 'setting_tag',
          transitionBetweenRoutes: false,
        middle: Text(tr('Setting'), style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        border: Border(bottom: BorderSide(color: Colors.transparent))
      ),
      body: SingleChildScrollView (
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(),
              _textSize(),

            ],
          ),
        )
      )
    );
  }

  Widget _textSize() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tr('Adjust text size')),
          Text("  "),
          Expanded(
            child: Obx(() => CupertinoSlider(
                value: textScaleController.textScale.value, // Use reactive variable
                min: 0.7,
                max: 1.7,
                divisions: 10,
                onChanged: (value) {
                  textScaleController.updateTextScale(value); // Ensure update method is reactive
                },
              ),
            ),
          )

        ],
      ),
    );
  }
}

//${textScaleController.textScale.value.toStringAsFixed(2)}x

/*
Obx(() => Text(tr('Adjust text size'), style: const TextStyle(fontSize: 16),),

Obx(() => CupertinoSlider(
                value: textScaleController.textScale.value, // Use reactive variable
                min: 0.7,
                max: 1.7,
                divisions: 10,
                onChanged: (value) {
                  textScaleController.updateTextScale(value); // Ensure update method is reactive
                },
              ),
            ),
 */