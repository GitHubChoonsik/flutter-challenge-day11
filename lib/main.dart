import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSwatch(backgroundColor: const Color(0xFFE74C3D)),
        textTheme: const TextTheme(
            headlineLarge: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
            displayMedium: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            )),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const twentyFiveMinutes = 1500;
  int totalSeconds = twentyFiveMinutes;
  bool isRunning = false;
  int totalPomodoros = 0;
  late Timer timer;
  static const candidateMins = [15, 20, 25, 30, 35];

  void onTick(Timer timer) {
    if (totalSeconds == 0) {
      setState(() {
        totalPomodoros = totalPomodoros + 1;
        isRunning = false;
        totalSeconds = twentyFiveMinutes;
      });
      timer.cancel();
    } else {
      setState(() {
        totalSeconds = totalSeconds - 1;
      });
    }
  }

  void onStartPressed() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      onTick,
    );
    setState(() {
      isRunning = true;
    });
  }

  void onPausePressed() {
    timer.cancel();
    setState(() {
      isRunning = false;
    });
  }

  String format(int seconds) {
    var duration = Duration(seconds: seconds);
    return duration.toString().split(".").first.substring(2, 7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          Flexible(
            flex: 1,
            child: Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                'POMOTIMER',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Text(
                format(totalSeconds),
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  // color: Color(0xFF000000),
                  fontSize: 89,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: ShaderMask(
              shaderCallback: (bounds) => RadialGradient(
                colors: [
                  Colors.black,
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
                center: Alignment.center,
                radius: 4.0,
              ).createShader(
                Rect.fromLTRB(0, 0, bounds.width, bounds.height),
              ),
              blendMode: BlendMode.dstIn,
              child: SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: candidateMins.length,
                  // itemBuilder: (BuildContext context, int index) => Text(
                  //   '${candidateMins[index]}',
                  // ),
                  itemBuilder: (BuildContext context, int index) => Container(
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "${candidateMins[index]}",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                  ),
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Center(
              child: IconButton(
                iconSize: 120,
                color: Theme.of(context).cardColor,
                onPressed: isRunning ? onPausePressed : onStartPressed,
                icon: Icon(isRunning
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pomodoros',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.displayLarge!.color,
                          ),
                        ),
                        Text(
                          '$totalPomodoros',
                          style: TextStyle(
                            fontSize: 58,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.displayLarge!.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
