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
      shrinkDuration: const Duration(milliseconds: 500),
      fadeInDuration: const Duration(milliseconds: 300),
    );
    controller2 = ShrinkSheetController.simple(
      vsync: this,
      shrinkDuration: const Duration(milliseconds: 1000),
      fadeInDuration: const Duration(milliseconds: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    const animDuration = Duration(milliseconds: 500);
    final anim1 = ShrinkSheetController.simple(
      vsync: this,
      shrinkDuration: animDuration,
      fadeInDuration: animDuration,
    );
    final anim2 = ShrinkSheetController.simple(
      vsync: this,
      shrinkDuration: animDuration,
      fadeInDuration: animDuration,
    );
    return Scaffold(
      body: ShrinkSheetLayout(
        animation: anim1,
        shrinkHeight: 60,
        toPadding: const EdgeInsets.only(bottom: 60),
        contentBuilder: ShrinkSheetContentBuilder.simple(
          thumb: ShrinkThumbConstraint.resize(
            min: 60,
            max: 200,
            child: ShrinkSheetThumb(
              child: Container(
                color: Colors.grey[800],
                child: Center(
                  child: Text(
                    "bar1",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.background,
                        ),
                  ),
                ),
              ),
            ),
          ),
          content: ShrinkSheetLayout(
            animation: anim2,
            shrinkHeight: 60,
            fromPadding: const EdgeInsets.only(top: 2),
            toPadding: const EdgeInsets.all(8),
            contentBuilder: ShrinkSheetContentBuilder.simple(
              thumb: ShrinkThumbConstraint.fixed(
                size: 60,
                child: ShrinkSheetThumb(
                  child: Container(
                    color: Colors.grey,
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          anim2.fadeOut();
                        },
                        child: Text("bar2"),
                      ),
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
                anim1.shrink();
                anim2.expand();
              },
              child: const Text("body"),
            ),
          ),
        ),
        body: TextButton(
          onPressed: () {
            log("test");
            anim1.expand();
            anim2.fadeIn();
          },
          child: const Text("body"),
        ),
      ),
    );
  }
}
