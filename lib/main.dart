import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_win_resize_bug/winapi_helper.dart';

const Size defaultWindowSize = Size(400, 100);

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // color: Colors.transparent,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isExpanded = false;
  Size currentSize = defaultWindowSize;

  @override
  void initState() {
    super.initState();

    _resizeWindow(defaultWindowSize);

    // Timer.periodic(Duration(milliseconds: 200), (timer) {
    //   _expandOrCollapse();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.green,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: defaultWindowSize.width,
              height: defaultWindowSize.height,
              color: Colors.orange,
              child: Column(
                children: [
                  const Expanded(
                    child: SizedBox(),
                  ),
                  Container(
                    height: 100,
                    alignment: Alignment.center,
                    // color: Colors.red,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Icon(Icons.home, color: Colors.white),
                        const Icon(Icons.bug_report_outlined,
                            color: Colors.white),
                        TextButton(
                          onPressed: () async {
                            await _expandOrCollapse();
                          },
                          child: Text(isExpanded ? 'Collapse' : 'Expand',
                              style: const TextStyle(color: Colors.white)),
                        ),
                        const Icon(Icons.cloud, color: Colors.white),
                        const Icon(Icons.flag, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _expandOrCollapse() async {
    isExpanded = !isExpanded;
    var newSize = isExpanded ? const Size(400, 300) : defaultWindowSize;

    _resizeWindow(newSize);
    // if (mounted) {
    //   setState(() {
    //     currentSize = newSize;
    //   });
    // }
  }

  void _resizeWindow(Size newSize) async {
    var currentBounds = WinApiHelper.getBounds();
    var heightOffset = currentBounds.height - newSize.height;
    Rect newFrame = Rect.fromLTWH(currentBounds.left,
        currentBounds.top + heightOffset, newSize.width, newSize.height);

    await WinApiHelper.setBounds(newFrame);
  }
}
