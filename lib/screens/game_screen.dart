import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/game_enums.dart';
import '../services/game_state.dart';
import '../services/storage_service.dart';
import '../services/effects_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _winAnimationController;
  late Animation<double> _winAnimation;
  bool _showWinOverlay = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _winAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _winAnimation = CurvedAnimation(
      parent: _winAnimationController,
      curve: Curves.easeOut,
    );
    _loadNewImage();
  }

  void _loadNewImage() {
    final gameState = context.read<GameState>();
    final storage = context.read<StorageService>();
    final theme = storage.getTheme();
    
    if (!theme.isTexture) {
      final query = theme.unsplashQuery ?? 'nature';
      final random = Random();
      _imageUrl = 'https://source.unsplash.com/${query}/${400 + random.nextInt(10)}x${400 + random.nextInt(10)}?sig=${random.nextInt(1000)}';
      gameState.setImageUrl(_imageUrl!);
    }
  }

  @override
  void dispose() {
    _winAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final storage = context.read<StorageService>();

    if (gameState.isCompleted && !_showWinOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWinOverlay = true;
        final effects = EffectsService();
        effects.setSoundEnabled(storage.getSoundEnabled());
        effects.setVibrationEnabled(storage.getVibrationEnabled());
        effects.celebrateWin(gameState.isNewRecord);
        _winAnimationController.forward();
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(gameState),
            Expanded(
              child: Center(
                child: _buildGameBoard(gameState, storage),
              ),
            ),
            _buildRestartButton(),
            if (_showWinOverlay && gameState.isCompleted) _buildWinOverlay(gameState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(GameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStat('⏱', _formatTime(gameState.seconds)),
          const SizedBox(width: 48),
          _buildStat('🎯', 'Ходов: ${gameState.moves}'),
        ],
      ),
    );
  }

  Widget _buildStat(String icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildGameBoard(GameState gameState, StorageService storage) {
    final size = gameState.mode.size;
    final tileSize = min(300.0, (MediaQuery.of(context).size.width - 48) / size);
    final theme = storage.getTheme();
    
    return Container(
      width: tileSize * size + 4,
      height: tileSize * size + 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(4, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Stack(
        children: [
          for (int i = 0; i < gameState.tiles.length; i++)
            if (gameState.tiles[i] != 0)
              _buildTile(
                gameState,
                i,
                tileSize,
                theme,
                gameState.tiles[i],
              ),
        ],
      ),
    );
  }

  Widget _buildTile(
    GameState gameState,
    int index,
    double tileSize,
    GameTheme theme,
    int value,
  ) {
    final row = index ~/ gameState.mode.size;
    final col = index % gameState.mode.size;
    final canMove = gameState.canMove(index);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      left: col * tileSize + 2,
      top: row * tileSize + 2,
      child: GestureDetector(
        onTap: canMove ? () => gameState.move(index) : null,
        child: AnimatedBuilder(
          animation: _winAnimation,
          builder: (context, child) {
            return Container(
              width: tileSize - 4,
              height: tileSize - 4,
              decoration: BoxDecoration(
                color: _getTileColor(theme, value, canMove),
                borderRadius: BorderRadius.circular(6),
                image: !theme.isTexture && _imageUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(_imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x20000000),
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: tileSize - 8,
                  height: tileSize - 8,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getTileColor(GameTheme theme, int value, bool canMove) {
    switch (theme) {
      case GameTheme.wood:
        return Color.lerp(const Color(0xFF8B4513), const Color(0xFFA0522D), (value - 1) / 14)!;
      case GameTheme.marble:
        return Color.lerp(const Color(0xFFE0E0E0), const Color(0xFFBDBDBD), (value - 1) / 14)!;
      case GameTheme.neon:
        return Colors.black;
      case GameTheme.blackWhite:
        return Color.lerp(const Color(0xFF424242), const Color(0xFF212121), (value - 1) / 14)!;
      default:
        return const Color(0xFFE0E0E0);
    }
  }

  Widget _buildRestartButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showWinOverlay = false;
            _winAnimationController.reset();
          });
          context.read<GameState>().restart();
          _loadNewImage();
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('↺', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'Перезапуск',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinOverlay(GameState gameState) {
    return AnimatedBuilder(
      animation: _winAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _winAnimation.value,
          child: Container(
            color: Colors.black.withOpacity(0.5 * _winAnimation.value),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Время',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(_winAnimation.value),
                    ),
                  ),
                  Text(
                    _formatTime(gameState.seconds),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(_winAnimation.value),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ходов: ${gameState.moves}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white.withOpacity(_winAnimation.value),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showWinOverlay = false;
                        _winAnimationController.reset();
                      });
                      context.read<GameState>().restart();
                      _loadNewImage();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Играть снова',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(_winAnimation.value),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
