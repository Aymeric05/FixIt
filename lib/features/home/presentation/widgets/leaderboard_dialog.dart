import 'package:flutter/material.dart';
import 'candy_dialog.dart';
import '../../../../core/theme/app_colors.dart';

class LeaderboardDialog extends StatefulWidget {
  const LeaderboardDialog({super.key});

  @override
  State<LeaderboardDialog> createState() => _LeaderboardDialogState();
}

class _LeaderboardDialogState extends State<LeaderboardDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return CandyDialog(
      title: 'RANKINGS',
      content: SizedBox(
        height: 400,
        width: 300,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabIndicator(0, 'GLOBAL'),
                const SizedBox(width: 20),
                _buildTabIndicator(1, 'WORLD 1'),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildLeaderboardList('Global'),
                  _buildLeaderboardList('World 1'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Slide to switch',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabIndicator(int index, String label) {
    final active = _currentPage == index;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: active ? AppColors.candyPink : Colors.grey,
            fontSize: 14,
          ),
        ),
        Container(
          height: 4,
          width: 40,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.candyPink : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(String scope) {
    final players = [
      {'name': 'CandyKing', 'score': '1500', 'rank': 1},
      {'name': 'PuzzlePro', 'score': '1420', 'rank': 2},
      {'name': 'SweetTooth', 'score': '1380', 'rank': 3},
      {'name': 'SugarRush', 'score': '1250', 'rank': 4},
      {'name': 'CookieMonster', 'score': '1100', 'rank': 5},
    ];

    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.candyBlue.withOpacity(0.2), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _getRankColor(player['rank'] as int),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${player['rank']}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  player['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown),
                ),
              ),
              Text(
                '${player['score']}',
                style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.candyBlue),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.brown.shade300;
    return AppColors.candyBlue;
  }
}
