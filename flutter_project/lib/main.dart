import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'services/storage_service.dart';

/// TrackWise - Personal Expense Tracker
/// A complete Flutter application for tracking daily expenses
/// 
/// Features:
/// - View total expenses with animated summary
/// - Add/Edit/Delete expenses with validation
/// - Search and filter expenses
/// - Analytics dashboard with charts
/// - Category-based expense organization
/// - Clean Material Design UI
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive storage
  await StorageService.init();
  
  runApp(const TrackWiseApp());
}

class TrackWiseApp extends StatelessWidget {
  const TrackWiseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackWise - Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Modern color scheme with purple accent
        primarySwatch: Colors.deepPurple,
        primaryColor: const Color(0xFF6C63FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        
        // Card theme
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        
        // Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
        ),
        
        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
        ),
      ),
      
      // Set home screen as the initial route
      home: const MainNavigationScreen(),
    );
  }
}
