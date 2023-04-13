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
        colorScheme: ColorScheme.fromSwatch(
          backgroundColor: const Color(0xFFE74C3D),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
          displayLarge: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
          displayMedium: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w600,
          ),
        ),
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
  static const double minsWidth = 70, minsSpace = 10;
  static const List<int> mins = [15, 20, 25, 30, 35];
  static const int initailMin = 2;

  static const int maxRound = 4, maxGoal = 12;
  int roundPomodoros = 0, goalPomodoros = 0;
  bool releaseRest = false;
  bool isRunning = false;
  bool isResting = false;
  late Timer timer;
  late Timer restTimer;

  int currentMin = initailMin;
  int totalSeconds = mins[initailMin] * 60;
  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 40 + ((minsWidth + minsSpace) * 2),
  );

  void onClickMins(index) {
    if (isResting) return;
    _scrollController.animateTo(
      40 + ((minsWidth + minsSpace) * index),
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
    setState(() {
      currentMin = index;
      isRunning = false;
      totalSeconds = mins[currentMin] * 60;
    });
    if (isRunning) timer.cancel();
  }

  void onTick(Timer timer) {
    if (totalSeconds == 0) {
      setState(() {
        roundPomodoros++;
        isRunning = false;
        totalSeconds = mins[currentMin] * 60;

        if (roundPomodoros == maxRound) {
          roundPomodoros = 0;
          goalPomodoros++;
          if (goalPomodoros == maxGoal) {
            goalPomodoros = 0;
          }
        }
      });
      timer.cancel();
      onRest();
    } else {
      setState(() {
        totalSeconds = totalSeconds - 1;
      });
    }
  }

  void onRestTick(Timer restTimer) {
    if (totalSeconds == 0) {
      setState(() {
        isResting = false;
        isRunning = false;
        totalSeconds = mins[currentMin] * 60;
      });
      restTimer.cancel();
    } else {
      setState(() {
        totalSeconds = totalSeconds - 1;
      });
    }
  }

  void onRest() {
    setState(() {
      isResting = true;
      isRunning = true;
      totalSeconds = 300;
    });
    restTimer = Timer.periodic(
      const Duration(seconds: 1),
      onRestTick,
    );
  }

  void onStartPressed() {
    if (isResting) {
      restTimer = Timer.periodic(
        const Duration(seconds: 1),
        onTick,
      );
    } else {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        onTick,
      );
    }
    setState(() {
      isRunning = true;
      releaseRest = true;
    });
  }

  void onPausePressed() {
    timer.cancel();
    if (isResting) restTimer.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void onResetPressed() {
    if (!releaseRest) return;
    timer.cancel();
    if (isResting) restTimer.cancel();
    setState(() {
      isRunning = false;
      isResting = false;
      roundPomodoros = 0;
      goalPomodoros = 0;
      totalSeconds = mins[currentMin] * 60;
    });
  }

  String format(int seconds) {
    var duration = Duration(seconds: seconds);
    return duration.toString().split(".").first.substring(2, 7);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isResting
          ? const Color(0xFFBDD9FF)
          : Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          const SizedBox(
            height: 60,
          ),
          Flexible(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'POMOTIMER',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    isResting ? 'A five-minute break' : '',
                    style: Theme.of(context).textTheme.headlineLarge,
                  )
                ],
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
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: mins.length,
                  itemBuilder: (BuildContext lContext, int index) => Row(
                    children: [
                      if (index == 0)
                        const SizedBox(
                          width: 200,
                        ),
                      const SizedBox(
                        width: minsSpace,
                      ),
                      Container(
                        width: minsWidth,
                        decoration: BoxDecoration(
                          color: currentMin == index ? Colors.white : null,
                          border: Border.all(
                            color: Colors.white,
                            strokeAlign: BorderSide.strokeAlignCenter,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => onClickMins(index),
                          child: Text(
                            "${mins[index]}",
                            style: currentMin == index
                                ? TextStyle(
                                    color: isResting
                                        ? const Color(0xFFBDD9FF)
                                        : Theme.of(context)
                                            .colorScheme
                                            .background,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w600,
                                  )
                                : Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                      ),
                      if (index == mins.length - 1)
                        const SizedBox(
                          width: 200,
                        ),
                    ],
                  ),
                  separatorBuilder: (BuildContext lContext, int index) =>
                      const Divider(),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 120,
                    color: Theme.of(context).cardColor,
                    onPressed: isRunning ? onPausePressed : onStartPressed,
                    icon: Icon(isRunning
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline),
                  ),
                  IconButton(
                    iconSize: 30,
                    color: Theme.of(context).cardColor,
                    onPressed: onResetPressed,
                    icon: const Icon(Icons.restore),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$roundPomodoros/$maxRound',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .color!
                                  .withOpacity(0.5),
                            ),
                          ),
                          Text(
                            'ROUND',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .color,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '$goalPomodoros/$maxGoal',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .color!
                                  .withOpacity(0.5),
                            ),
                          ),
                          Text(
                            'GOAL',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge!
                                  .color,
                            ),
                          ),
                        ],
                      ),
                    ],
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
