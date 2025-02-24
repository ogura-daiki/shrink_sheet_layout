import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shrink_sheet_layout/shrink_sheet_layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: SafeArea(
          child: MyHomePage(),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final ShrinkSheetController controller1;
  late final ShrinkSheetController controller2;
  @override
  void initState() {
    super.initState();
    controller1 = ShrinkSheetController.simple(
      vsync: this,
      shrinkDuration: const Duration(milliseconds: 1000),
      fadeInDuration: const Duration(milliseconds: 1000),
    );
    controller2 = ShrinkSheetController.simple(
      vsync: this,
      shrinkDuration: const Duration(milliseconds: 500),
      fadeInDuration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShrinkSheetLayout(
        animation: controller1,
        shrinkHeight: 60,
        shrinkPadding: const EdgeInsets.only(bottom: 60),
        backdropColor: Theme.of(context).colorScheme.background,
        backdropMaxOpacity: 1,
        backdropOpacityFactor: 0.5,
        contentBuilder: ShrinkSheetContentBuilder.simple(
          thumbSizeCalculator: ThumbSizeCalculator.fit(
              MediaQuery.of(context).size.width / 16 * 9),
          thumb: ShrinkSheetThumb(
            child: Container(
              color: Colors.grey[800],
              child: Center(
                child: Text(
                  "VIDEO AREA",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.background,
                      ),
                ),
              ),
            ),
          ),
          content: ShrinkSheetLayout(
            animation: controller2,
            shrinkHeight: 60,
            expandPadding: const EdgeInsets.only(top: 2),
            shrinkPadding: const EdgeInsets.all(8),
            paddingDodgeSheet: 120,
            minPaddingDodgeSheet: 60,
            contentBuilder: ShrinkSheetContentBuilder.simple(
              thumbSizeCalculator: ThumbSizeCalculator.fit(60),
              thumb: ShrinkSheetThumb(
                child: Container(
                  color: Colors.grey,
                  child: Center(
                    child: TextButton(
                      onPressed: controller2.fadeOut,
                      child: Text("click here to fadeout sheet"),
                    ),
                  ),
                ),
              ),
              content: Container(
                color: Colors.amber,
                child: const Center(child: Text("text")),
              ),
            ),
            body: TextButton(
              onPressed: () {
                log("test");
                controller1.shrink();
                controller2.expand();
              },
              child: const Text("body"),
            ),
          ),
        ),
        body: TextButton(
          onPressed: () {
            log("test");
            controller1.expand();
            controller2.fadeIn();
          },
          child: const Text("body"),
        ),
      ),
    );
  }
}
