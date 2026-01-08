import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'services/product_service.dart';
import 'screens/home_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const FbblApp());
}

class FbblApp extends StatelessWidget {
  const FbblApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider(ProductService()),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final tp = ThemeProvider();
            tp.load();
            return tp;
          },
        ),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          title: 'Food Corners',
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: context.watch<ThemeProvider>().mode,
          home: const _RootNav(),
          onGenerateRoute: (settings) {
            if (settings.name == ProductDetailScreen.routeName) {
              final args = settings.arguments as ProductDetailArgs;
              return MaterialPageRoute(
                builder: (_) => ProductDetailScreen(product: args.product),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}

ThemeData _buildLightTheme() {
  // Burger King-inspired palette: red, yellow, green
  const bkRed = Color(0xFFE31837);
  const bkYellow = Color(0xFFFFC72C);
  const bkGreen = Color(0xFF2AB573);

  final baseScheme = ColorScheme.fromSeed(seedColor: bkRed, brightness: Brightness.light);
  final colorScheme = baseScheme.copyWith(
    primary: bkRed,
    primaryContainer: Color.alphaBlend(bkRed.withOpacity(0.18), baseScheme.surface),
    secondary: bkYellow,
    secondaryContainer: Color.alphaBlend(bkYellow.withOpacity(0.18), baseScheme.surface),
    tertiary: bkGreen,
    tertiaryContainer: Color.alphaBlend(bkGreen.withOpacity(0.18), baseScheme.surface),
  );
  final base = ThemeData(useMaterial3: true, colorScheme: colorScheme, brightness: Brightness.light);
  final background = Color.alphaBlend(colorScheme.primary.withOpacity(0.04), colorScheme.surface);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    brightness: Brightness.light,
    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.15),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, letterSpacing: -0.1),
      bodyMedium: GoogleFonts.inter(height: 1.25),
      bodySmall: GoogleFonts.inter(height: 1.2),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primary.withOpacity(0.15),
      iconTheme: WidgetStateProperty.resolveWith((states) =>
          IconThemeData(color: states.contains(WidgetState.selected) ? colorScheme.primary : colorScheme.onSurfaceVariant)),
      labelTextStyle: WidgetStateProperty.all(TextStyle(color: colorScheme.onSurfaceVariant)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(colorScheme.primary),
        foregroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(colorScheme.primary),
        side: WidgetStateProperty.all(BorderSide(color: colorScheme.primary.withOpacity(0.5))),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardTheme(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
    ),
  );
}

ThemeData _buildDarkTheme() {
  // Burger King-inspired palette: red, yellow, green
  const bkRed = Color(0xFFE31837);
  const bkYellow = Color(0xFFFFC72C);
  const bkGreen = Color(0xFF2AB573);

  final baseScheme = ColorScheme.fromSeed(seedColor: bkRed, brightness: Brightness.dark);
  final colorScheme = baseScheme.copyWith(
    primary: bkRed,
    primaryContainer: Color.alphaBlend(bkRed.withOpacity(0.25), baseScheme.surface),
    secondary: bkYellow,
    secondaryContainer: Color.alphaBlend(bkYellow.withOpacity(0.22), baseScheme.surface),
    tertiary: bkGreen,
    tertiaryContainer: Color.alphaBlend(bkGreen.withOpacity(0.22), baseScheme.surface),
  );
  final base = ThemeData(useMaterial3: true, colorScheme: colorScheme, brightness: Brightness.dark);
  final background = Color.alphaBlend(colorScheme.primary.withOpacity(0.06), colorScheme.surface);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.2),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.15),
      titleSmall: GoogleFonts.inter(fontWeight: FontWeight.w600, letterSpacing: -0.1),
      bodyMedium: GoogleFonts.inter(height: 1.25),
      bodySmall: GoogleFonts.inter(height: 1.2),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primary.withOpacity(0.25),
      iconTheme: WidgetStateProperty.resolveWith((states) =>
          IconThemeData(color: states.contains(WidgetState.selected) ? colorScheme.primary : colorScheme.onSurfaceVariant)),
      labelTextStyle: WidgetStateProperty.all(TextStyle(color: colorScheme.onSurfaceVariant)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(colorScheme.primary),
        foregroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(colorScheme.primary),
        side: WidgetStateProperty.all(BorderSide(color: colorScheme.primary.withOpacity(0.5))),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardTheme(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
    ),
  );
}

class _RootNav extends StatefulWidget {
  const _RootNav();
  @override
  State<_RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<_RootNav> {
  int _index = 0;
  final _pages = const [
    HomeScreen(),
    ProductListScreen(),
    ContactScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.contact_mail_outlined), selectedIcon: Icon(Icons.contact_mail), label: 'Contact'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
