import 'package:flutter/material.dart';
import 'memcoin_overlay_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF4E2A84), // Градиент начинается с фиолетового
                Color(0xFF2C0054), // И заканчивается более тёмным фиолетовым
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: MemcoinOverlayWidget(
              apiUrl: 'https://api.geckoterminal.com/api/v2/networks/ton/pools/EQAf2LUJZMdxSAGhlp-A60AN9bqZeVM994vCOXH05JFo-7dc',
              memcoinName: 'GOVNO TOP 777',
              memcoinAmount: 'Ton GOVNO',
            ),
          ),
        ),
      ),
    );
  }
}
