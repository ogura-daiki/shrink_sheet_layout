<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

This is a draggable bottom sheet plugin, like the one in the app version of Youtube.

## Features

You can add a draggable bottom sheet to your app, like the one in the Youtube app.

Showing and hiding sheets is not yet supported.

![shrink_sheet_layout demo](https://github.com/user-attachments/assets/73fc2238-fae6-48c4-b9e0-34c289be8762)

## Getting started

Feel free to add to your existing Flutter apps.
No preparation is required other than a Flutter app project.

Import the package by running the following command on the command line.

`dart pub add shrink_sheet_layout`

Then use it in the build function as shown in the example in the Usage column.

## Usage

```dart

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shrink_sheet_layout/shrink_sheet_layout.dart';

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


```

## Additional information

最初のパッケージリリースであることに加え、これは私自身のために作った最初のパッケージでもある。
メンテナンスの速さは期待しないでほしい。
