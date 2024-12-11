import 'dart:async';
import 'dart:js_interop' as js;
import 'dart:js_interop_unsafe' as js_util;

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

@js.JSExport()
class _MyAppState extends State<MyApp> {
  final _streamController = StreamController<void>.broadcast();
  int _counterScreenCount = 0;
  String _inputText = ""; // New: To store input text from JavaScript

  @override
  void initState() {
    super.initState();
    final export = js.createJSInteropWrapper(this);
    js.globalContext['_appState'] = export;
    js.globalContext.callMethod('_stateSet'.toJS);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @js.JSExport()
  void increment() {
    setState(() {
      _counterScreenCount++;
      _streamController.add(null);
    });
  }

  @js.JSExport()
  void decrement() {
    setState(() {
      _counterScreenCount--;
      _streamController.add(null);
    });
  }

  // New: Method to handle input from JavaScript
  @js.JSExport()
  void updateInput(String input) {
    setState(() {
      _inputText = input; // Update the state with the new input
      _streamController.add(null);
    });
  }

  @js.JSExport()
  void addHandler(void Function() handler) {
    _streamController.stream.listen((event) {
      handler();
    });
  }

  @js.JSExport()
  int get count => _counterScreenCount;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-View Embedding Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      debugShowCheckedModeBanner: false,
      home: CounterDemo(
        title: 'Counter',
        numToDisplay: _counterScreenCount,
        inputText: _inputText, // Pass the input text to the CounterDemo widget
        incrementHandler: increment,
        decrementHandler: decrement,
      ),
    );
  }
}

class CounterDemo extends StatefulWidget {
  final String title;
  final int numToDisplay;
  final String inputText; // New: Input text from JS
  final VoidCallback incrementHandler;
  final VoidCallback decrementHandler;

  const CounterDemo({
    super.key,
    required this.title,
    required this.numToDisplay,
    required this.inputText,
    required this.incrementHandler,
    required this.decrementHandler,
  });

  @override
  State<CounterDemo> createState() => _CounterDemoState();
}

class _CounterDemoState extends State<CounterDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '${widget.numToDisplay}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            const Text('Input Text from JavaScript:'),
            Text(
              widget.inputText, // Display the input text
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: widget.incrementHandler,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: widget.decrementHandler,
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
