import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_enums.dart';
import '../models/game_record.dart';
import '../services/storage_service.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  GameMode _selectedMode = GameMode.fourByFour;
  List<GameRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final storage = context.read<StorageService>();
    final records = await storage.getRecords(_selectedMode);
    setState(() {
      _records = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildModeTabs(),
            Expanded(
              child: _buildRecordsList(),
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
          const Text('🏆', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          const Text(
            'Рекорды',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: GameMode.values.map((mode) {
            final isSelected = mode == _selectedMode;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMode = mode;
                });
                _loadRecords();
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mode.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📭', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text(
              'Пока нет рекордов',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _records.length,
              itemBuilder: (context, index) => _buildRecordTile(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Время',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Ходы',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordTile(int index) {
    final record = _records[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: index == 0 
            ? const Color(0xFFFFD700).withOpacity(0.2)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: index == 0 
            ? Border.all(color: const Color(0xFFFFD700), width: 2)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: index == 0 ? const Color(0xFFFFD700) : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _formatTime(record.seconds),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: index == 0 ? const Color(0xFFFFD700) : Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${record.moves}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: index == 0 ? const Color(0xFFFFD700) : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
