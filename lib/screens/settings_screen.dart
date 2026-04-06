import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_state.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.read<StorageService>();
    final gameState = context.read<GameState>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildToggle(
                      context,
                      'Звук',
                      storage.getSoundEnabled(),
                      (value) {
                        storage.saveSoundEnabled(value);
                        gameState.notifyListeners();
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildToggle(
                      context,
                      'Вибрация',
                      storage.getVibrationEnabled(),
                      (value) {
                        storage.saveVibrationEnabled(value);
                        gameState.notifyListeners();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, size: 28),
          ),
          const SizedBox(width: 16),
          const Text(
            'Настройки',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
    BuildContext context,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: value ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value ? 'ВКЛ' : 'ВЫКЛ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: value ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
