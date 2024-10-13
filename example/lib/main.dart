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
    controller1 = ShrinkSheetController(
      controller: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
        value: 1,
      ),
    );
    controller2 = ShrinkSheetController(
      controller: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
        value: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShrinkSheetLayout(
        animation: controller1,
        minHeight: 60,
        thumbHeight: 200,
        resizeThumb: true,
        toPadding: const EdgeInsets.only(bottom: 60),
        thumb: Container(
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
        resizeContent: false,
        sheetContent: ShrinkSheetLayout(
          animation: controller2,
          thumbHeight: 60,
          fromPadding: const EdgeInsets.only(top: 2),
          toPadding: const EdgeInsets.all(8),
          thumb: Container(
            color: Colors.grey,
            child: const Center(child: Text("bar2")),
          ),
          sheetContent: Container(
            color: Colors.amber,
            child: const Center(child: Text("text")),
          ),
          body: TextButton(
            onPressed: () {
              log("test");
              controller2.expand();
            },
            child: const Text("body"),
          ),
        ),
        body: TextButton(
          onPressed: () {
            log("test");
            controller1.expand();
          },
          child: const Text("body"),
        ),
      ),
    );
  }
}
