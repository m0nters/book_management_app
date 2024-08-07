import 'package:flutter/material.dart';
import 'routing/overall_screen_routing.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:month_year_picker/month_year_picker.dart';

void main() {
  runApp(const BookstoreManagementApp());
}

class BookstoreManagementApp extends StatelessWidget {
  const BookstoreManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('vi'), // Set Vietnamese as the default locale
      supportedLocales: const [
        Locale('vi'), // Add Vietnamese to the list of supported locales
      ],
      localizationsDelegates: const [
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Archivo",
        // splashColor: Colors.transparent, // Disable splash for taps
        // highlightColor: Colors.transparent, // Disable highlight for long presses
      ),
      home: const SafeArea(child: OverallScreenRouting()),
      // home: const BookEntryFormSearch()
    );
  }
}
