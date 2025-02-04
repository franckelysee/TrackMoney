import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackmoney/DataBase/database.dart';
import 'package:trackmoney/templates/home.dart';
import 'package:trackmoney/templates/pages/auth/auth.dart';
import 'package:trackmoney/routes/init_routes.dart';
import 'package:trackmoney/utils/app_config.dart';

void main() async {
  await Database.initHive(); // Initialisation de Hive

  // Vérification de l'état de l'utilisateur
  bool isFirstLauch = await Database.isFirstLaunch();

  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(
        isFirstLaunch: isFirstLauch,
      )));
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;
  const MyApp({super.key, required this.isFirstLaunch});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      onGenerateRoute: onGenerateRoute,
      home: isFirstLaunch ? const AuthPage() : const HomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
