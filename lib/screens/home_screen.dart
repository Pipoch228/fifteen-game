import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_enums.dart';
import '../services/game_state.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'records_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final storage = context.read<StorageService>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildModeSelector(context, gameState),
              const SizedBox(height: 12),
              _buildThemeSelector(context, storage, gameState),
              const SizedBox(height: 48),
              _buildPlayButton(context),
              const Spacer(),
              _buildMenuButtons(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context, GameState gameState) {
    return GestureDetector(
      onTap: () => _showModeSelector(context, gameState),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⊞', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              gameState.mode.label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, StorageService storage, GameState gameState) {
    return GestureDetector(
      onTap: () => _showThemeSelector(context, storage, gameState),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👁', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              gameState.currentImageUrl != null ? 'Картинка' : gameState.mode == GameMode.fourByFour 
                  ? 'Пейзажи' 
                  : gameState.mode.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GameScreen()),
        );
      },
      child: Container(
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'ИГРАТЬ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMenuButton(
          context,
          '⚙',
          'Настройки',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          ),
        ),
        const SizedBox(width: 32),
        _buildMenuButton(
          context,
          '🏆',
          'Рекорды',
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecordsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showModeSelector(BuildContext context, GameState gameState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Выбор режима',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...GameMode.values.map((mode) => _buildOptionTile(
                  context,
                  mode.label,
                  mode == gameState.mode,
                  () {
                    gameState.setMode(mode);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context, StorageService storage, GameState gameState) {
    final currentTheme = storage.getTheme();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Выбор темы',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...GameTheme.values.map((theme) => _buildOptionTile(
                  context,
                  theme.label,
                  theme == currentTheme,
                  () {
                    storage.saveTheme(theme);
                    gameState.restart();
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3).withOpacity(0.1) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: const Color(0xFF2196F3), width: 2) : null,
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF2196F3) : Colors.black,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              const Icon(Icons.check, color: Color(0xFF2196F3)),
            ],
          ],
        ),
      ),
    );
  }
}
