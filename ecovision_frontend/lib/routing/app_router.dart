import 'package:flutter/material.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/map/presentation/pages/map_page_osm.dart'; // OpenStreetMap ✅
import '../features/report/presentation/pages/report_page.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../common/widgets/custom_bottom_nav.dart';

/// Main router với bottom navigation
class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    MapPageOSM(), // OpenStreetMap - FREE, No API key!
    ReportPage(),
    ChatPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
