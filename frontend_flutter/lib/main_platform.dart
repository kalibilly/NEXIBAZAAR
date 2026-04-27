import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // Platform-specific initialization
  _initializePlatform();
  runApp(const MyApp());
}

void _initializePlatform() {
  // Android platform channel
  const platform = MethodChannel('com.nexibazaar.nexi_bazaar/native');
  
  // iOS and macOS notifications
  if (defaultTargetPlatform == TargetPlatform.iOS || 
      defaultTargetPlatform == TargetPlatform.macOS) {
    // Request permissions for notifications
    WidgetsFlutterBinding.ensureInitialized();
  }
  
  // Windows platform specific setup
  if (defaultTargetPlatform == TargetPlatform.windows) {
    // Window configuration happens in main.cpp
  }
  
  // Linux platform specific setup
  if (defaultTargetPlatform == TargetPlatform.linux) {
    // Desktop window settings
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexiBazaar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'NexiBazaar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text('Welcome to NexiBazaar'),
      ),
    );
  }
}
