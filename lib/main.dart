import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/home_screen.dart';
import 'viewmodels/coin_list_view_model.dart';

void main() {
  // We initialize the app by setting up the theme and state management
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We use MultiProvider to register all ViewModels that manage global state.
    return MultiProvider(
      providers: [
        // The CoinListViewModel is created here and listens for changes
        // in the API service calls, automatically fetching coins on creation.
        ChangeNotifierProvider(create: (_) => CoinListViewModel()),
      ],
      child: MaterialApp(
        title: 'Crypto Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Light Theme inspired by the design
          brightness: Brightness.light,
          primaryColor:
              const Color(0xFF7B61FF), // Primary accent color (Purple/Blue)
          scaffoldBackgroundColor:
              const Color(0xFFF9F9FB), // Very light gray background
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF7B61FF),
            brightness: Brightness.light,
          ).copyWith(
            secondary: const Color(0xFF50AF95), // Secondary accent (Green)
          ),
          fontFamily:
              'Poppins', // Changed font to Poppins for a more artistic/modern feel
          textTheme: const TextTheme(
            // Set default text colors for the light theme
            bodyLarge: TextStyle(color: Colors.black87),
            bodyMedium: TextStyle(color: Colors.black54),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // FIX APPLIED HERE: Changed CardTheme to CardThemeData to match the ThemeData property type.
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            shadowColor: Colors.grey.withOpacity(0.1),
          ),
          // Set progress indicator color
          progressIndicatorTheme: const ProgressIndicatorThemeData(
            color: Color(0xFF7B61FF),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
