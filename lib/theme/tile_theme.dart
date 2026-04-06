import 'package:flutter/material.dart';
import '../models/game_enums.dart';

class TileTheme {
  final Color backgroundColor;
  final Color textColor;
  final BorderRadius borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final ImageProvider? image;
  final Color borderColor;

  const TileTheme({
    required this.backgroundColor,
    required this.textColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.boxShadow,
    this.gradient,
    this.image,
    this.borderColor = Colors.transparent,
  });

  static TileTheme getTheme(GameTheme theme) {
    switch (theme) {
      case GameTheme.wood:
        return const TileTheme(
          backgroundColor: Color(0xFF8B4513),
          textColor: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        );
      case GameTheme.marble:
        return const TileTheme(
          backgroundColor: Color(0xFFE0E0E0),
          textColor: Color(0xFF424242),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        );
      case GameTheme.neon:
        return TileTheme(
          backgroundColor: Colors.black,
          textColor: Colors.cyan,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          boxShadow: const [
            BoxShadow(
              color: Colors.cyan,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
          borderColor: Colors.cyan,
        );
      case GameTheme.blackWhite:
        return const TileTheme(
          backgroundColor: Color(0xFF212121),
          textColor: Colors.white,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF424242), Color(0xFF212121), Color(0xFF000000)],
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x60000000),
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        );
      case GameTheme.landscapes:
      case GameTheme.nature:
      case GameTheme.abstract:
      case GameTheme.animals:
        return const TileTheme(
          backgroundColor: Color(0xFFE0E0E0),
          textColor: Color(0xFF424242),
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        );
    }
  }
}
