import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

const Size defaultWindowSize = Size(400, 60);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: defaultWindowSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.transparent,
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
  Duration animationDuration = const Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const SizedBox(),
        Positioned(
          bottom: 0,
          child: AnimatedContainer(
            width: currentSize.width,
            height: currentSize.height,
            curve: Curves.fastOutSlowIn,
            duration: animationDuration,
            color: Colors.black38,
            child: Column(
              children: [
                const Expanded(
                  child: SizedBox(),
                ),
                Container(
                  height: defaultWindowSize.height,
                  alignment: Alignment.center,
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
                      IconButton(
                          onPressed: () async {
                            await windowManager.close();
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future _expandOrCollapse() async {
    isExpanded = !isExpanded;
    var newSize = isExpanded ? const Size(400, 200) : defaultWindowSize;

    if (isExpanded) {
      await _resizeWindow(newSize);
      setState(() {
        currentSize = newSize;
      });
    } else {
      setState(() {
        currentSize = newSize;
      });
      await Future.delayed(animationDuration);
      await _resizeWindow(newSize);
    }
  }

  Future _resizeWindow(Size newSize) async {
    var currentBounds = await windowManager.getBounds();
    var heightOffset = currentBounds.height - newSize.height;
    Rect newFrame = Rect.fromLTWH(currentBounds.left,
        currentBounds.top + heightOffset, newSize.width, newSize.height);

    await windowManager.setBounds(newFrame);
  }
}
