// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'monster_screen.dart';
import 'book_screen.dart';
import 'timer_screen.dart';
import 'settings_screen.dart';
import 'stomach_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleMenu() {
    if (isMenuOpen) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }
  
  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StomachScreen()),
              );
            },
            child: Image.asset(
              'assets/images/logo1.gif',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MonsterScreen()),
              );
            },
            child: const Text('育成をはじめる', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu() {
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.book, 'screen': const BookScreen()},
      {'icon': Icons.timer, 'screen': const TimerScreen()},
      {'icon': Icons.settings, 'screen': const SettingsScreen()},
    ];

    final animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOut);

    return Stack(
      children: List.generate(menuItems.length, (index) {
        final buttonTopPosition = 80.0 + (index * 65.0);

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final animationValue = animation.value;
            return Positioned(
              right: 20.0,
              top: 80.0 + (buttonTopPosition - 80.0) * animationValue,
              child: Opacity(
                opacity: animationValue,
                child: Transform.scale(
                  scale: animationValue,
                  child: child,
                ),
              ),
            );
          },
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              toggleMenu();
              Future.delayed(const Duration(milliseconds: 150), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => menuItems[index]['screen']),
                );
              });
            },
            child: Icon(menuItems[index]['icon']),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget darkener = isMenuOpen
        ? GestureDetector(
            onTap: toggleMenu,
            child: Container(color: Colors.black.withOpacity(0.3)),
          )
        : const SizedBox.shrink();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            iconSize: 45,
            color: Theme.of(context).colorScheme.primary,
            icon: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animationController,
            ),
            onPressed: toggleMenu,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMainContent(),
          darkener,
          _buildMenu(),
        ],
      ),
    );
  }
}