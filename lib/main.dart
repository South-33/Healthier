import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/chat/chat_page.dart';
import 'features/home/home_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/reference/reference_screen.dart';
import 'features/medications/medications_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthier',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF99B898), // Softer green
          brightness: Brightness.light,
          primary: const Color(0xFF99B898),
          surface: const Color(0xFFF7F6F4),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F6F4), // Lighter warm off-white
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
          displayLarge: GoogleFonts.lora(
            fontSize: 34,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
            color: const Color(0xFF1A1C19),
          ),
          headlineMedium: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1C19),
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1A1C19),
            height: 1.5,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF434942),
            height: 1.4,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: const Color(0xFFF7F6F4),
          foregroundColor: const Color(0xFF1A1C19),
          titleTextStyle: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1C19),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E332D),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: GoogleFonts.inter(color: const Color(0xFF8F928D)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF99B898), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      scrollBehavior: const _NoScrollbarBehavior(),
      builder: (context, child) {
        const mobileWidth = 470.0;
        const wideThreshold = 900.0;
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= wideThreshold;
            Widget phone = Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: mobileWidth),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Color(0xFFCBD5E1), width: 2),
                    boxShadow: const [
                      BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 12)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            );
            if (!isWide) return phone;
            return SizedBox.expand(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF7F7F9), Color(0xFFF0F3F8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Expanded(child: _SideInfo(alignment: Alignment.centerRight)),
                    const SizedBox(width: 24),
                    Container(width: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(width: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: phone,
                    ),
                    const SizedBox(width: 24),
                    Container(width: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(width: 24),
                    const Expanded(child: _SideInfo(alignment: Alignment.centerLeft)),
                  ],
                ),
              ),
            );
          },
        );
      },
      home: const AuthGate(child: MainScreen()),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final ValueNotifier<bool> _chatActive = ValueNotifier<bool>(false);
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const MedicationsScreen(),
      ChatPage(tabActiveNotifier: _chatActive),
      const ProfileScreen(),
    ];
    _chatActive.value = _currentIndex == 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _chatActive.value = index == 3;
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF99B898),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.vaccines_outlined),
              activeIcon: Icon(Icons.vaccines),
              label: 'Medications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_outlined),
              activeIcon: Icon(Icons.chat),
              label: 'AI Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
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
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _SideInfo extends StatelessWidget {
  final Alignment alignment;
  const _SideInfo({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isRight = alignment == Alignment.centerRight;
    final textAlign = isRight ? TextAlign.right : TextAlign.left;
    final crossAxis = isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final headingStyle = textTheme.titleLarge?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF111827),
      letterSpacing: 0.2,
    );
    final bodyStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 16,
      height: 1.6,
      color: const Color(0xFF475569),
    );
    final bulletTitleStyle = textTheme.bodyLarge?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF111827),
    );
    final bulletBodyStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 15,
      height: 1.55,
      color: const Color(0xFF475569),
    );
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SizedBox(
            height: double.infinity,
            child: Column(
              crossAxisAlignment: crossAxis,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Text(isRight ? 'What you can do' : 'Optimized for Mobile', style: headingStyle, textAlign: textAlign),
                const SizedBox(height: 12),
                Text(
                  isRight
                      ? 'Explore Healthier’s key features at a glance.'
                      : 'For the best experience, we render a phone-sized view on desktop. Use the side panels to explore features and tips.',
                  style: bodyStyle,
                  textAlign: textAlign,
                ),
                const SizedBox(height: 20),
                if (!isRight) ...[
                  _FeatureBullet(
                    icon: Icons.bolt,
                    title: 'Fast & Smooth',
                    body: 'Quick load times and fluid interactions.',
                    titleStyle: bulletTitleStyle,
                    bodyStyle: bulletBodyStyle,
                    textAlign: textAlign,
                  ),
                  _FeatureBullet(
                    icon: Icons.health_and_safety,
                    title: 'Health Insights',
                    body: 'Personalized metrics and guidance.',
                    titleStyle: bulletTitleStyle,
                    bodyStyle: bulletBodyStyle,
                    textAlign: textAlign,
                  ),
                  _FeatureBullet(
                    icon: Icons.lock,
                    title: 'Privacy First',
                    body: 'All your data stays secure.',
                    titleStyle: bulletTitleStyle,
                    bodyStyle: bulletBodyStyle,
                    textAlign: textAlign,
                  ),
                  const SizedBox(height: 8),
                ] else ...[
                  _FeatureBullet(
                    icon: Icons.smart_toy_outlined,
                    title: 'AI Chat',
                    body: 'Ask health questions, get guidance and reminders.',
                    titleStyle: bulletTitleStyle,
                    bodyStyle: bulletBodyStyle,
                    textAlign: textAlign,
                  ),
                  _FeatureBullet(
                    icon: Icons.vaccines_outlined,
                    title: 'Medication Tracking',
                    body: 'Plan doses, confirm intake, and get streaks.',
                    titleStyle: bulletTitleStyle,
                    bodyStyle: bulletBodyStyle,
                    textAlign: textAlign,
                  ),
                  _FeatureBullet(
                    icon: Icons.sos_outlined,
                    title: 'Emergency SOS',
                    body: 'Trigger urgent assistance with one tap.',
                    titleStyle: bulletTitleStyle,
                    bodyStyle: bulletBodyStyle,
                    textAlign: textAlign,
                  ),
                  _FeatureBullet(
                    icon: Icons.document_scanner_outlined,
                    title: 'Document Scanner',
                    body: 'Scan and store prescriptions and reports.',
                    titleStyle: bulletTitleStyle,
                    bodyStyle: bulletBodyStyle,
                    textAlign: textAlign,
                  ),
                  _FeatureBullet(
                    icon: Icons.notifications_active_outlined,
                    title: 'Smart Reminders',
                    body: 'Timely nudges tailored to your schedule.',
                    titleStyle: bulletTitleStyle,
                    bodyStyle: bulletBodyStyle,
                    textAlign: textAlign,
                  ),
                  _FeatureBullet(
                    icon: Icons.menu_book_outlined,
                    title: 'Reference Library',
                    body: 'Trusted health info at your fingertips.',
                    titleStyle: bulletTitleStyle,
                    bodyStyle: bulletBodyStyle,
                    textAlign: textAlign,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;
  final TextAlign textAlign;
  const _FeatureBullet({required this.icon, required this.title, required this.body, this.titleStyle, this.bodyStyle, this.textAlign = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: textAlign == TextAlign.right
            ? [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(title, style: titleStyle ?? const TextStyle(fontWeight: FontWeight.w600)),
                      Text(body, style: bodyStyle, textAlign: textAlign),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
              ]
            : [
                Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: titleStyle ?? const TextStyle(fontWeight: FontWeight.w600)),
                      Text(body, style: bodyStyle, textAlign: textAlign),
                    ],
                  ),
                ),
              ],
      ),
    );
  }
}

class _NoScrollbarBehavior extends MaterialScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
