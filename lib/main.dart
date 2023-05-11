
import 'package:budget_tracker/screens/home_screen.dart';
import 'package:budget_tracker/view_models/budget_view_model.dart';
import 'package:budget_tracker/services/local_storage.dart';
import 'package:budget_tracker/services/theme_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localStorageService = LocalStorageService();
  await localStorageService.initializeHive();
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({Key key, this.sharedPreferences}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>(create: (_) => ThemeService(sharedPreferences)),
        ChangeNotifierProvider<BudgetViewModel>(create: (_) => BudgetViewModel()),
      ],
      child: Builder(
        builder: (BuildContext context) {
          final themeService = Provider.of<ThemeService>(context);
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              // primarySwatch: Colors.red,
              colorScheme: ColorScheme.fromSwatch(
                brightness: themeService.darkTheme 
                ? Brightness.dark
                : Brightness.light, 
                primarySwatch: Colors.blueGrey),
              // colorScheme: ColorScheme.fromSeed(),
            ),
            home: Home(),
          );
        }
        ),
      );
  }
}

