import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fixit/core/theme/app_colors.dart';
import 'package:fixit/core/widgets/candy_button.dart';
import 'package:fixit/features/home/presentation/bloc/home_bloc.dart';
import 'package:fixit/features/home/presentation/widgets/candy_dialog.dart';
import 'dart:ui';

class ShopDialog extends StatelessWidget {
  const ShopDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return CandyDialog(
          title: 'SHOP',
          content: Column(
            children: [
              _buildCurrencyHeader(state.puzzlePieces),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.keyboard_arrow_down, color: Colors.black26, size: 20),
                  Text("SCROLL TO EXPLORE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26)),
                  Icon(Icons.keyboard_arrow_down, color: Colors.black26, size: 20),
                ],
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 450,
                width: 320,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildSectionTitle("SPECIAL ITEMS"),
                        _buildShopItem(
                          context,
                          icon: Icons.timer,
                          title: '+2 MINUTES',
                          description: 'Add 2 minutes to the timer',
                          count: state.itemPlusTime,
                          puzzleCost: 20,
                          moneyCost: 0.49,
                          onBuyPuzzles: () => context.read<HomeBloc>().add(const BuyItem('plus_time', 20)),
                          onBuyMoney: () => context.read<HomeBloc>().add(const BuyItem('plus_time', 0, isRealMoney: true)),
                        ),
                        const SizedBox(height: 10),
                        _buildShopItem(
                          context,
                          icon: Icons.format_list_numbered,
                          title: 'MORE NUMBERS',
                          description: 'Show 3 more numbers on grid',
                          count: state.itemMoreNumbers,
                          puzzleCost: 30,
                          moneyCost: 0.69,
                          onBuyPuzzles: () => context.read<HomeBloc>().add(const BuyItem('more_numbers', 30)),
                          onBuyMoney: () => context.read<HomeBloc>().add(const BuyItem('more_numbers', 0, isRealMoney: true)),
                        ),
                        const SizedBox(height: 10),
                        _buildShopItem(
                          context,
                          icon: Icons.auto_awesome,
                          title: 'REVEAL PATH',
                          description: 'Highlight next 4 steps',
                          count: state.itemRevealPath,
                          puzzleCost: 50,
                          moneyCost: 0.99,
                          onBuyPuzzles: () => context.read<HomeBloc>().add(const BuyItem('reveal_path', 50)),
                          onBuyMoney: () => context.read<HomeBloc>().add(const BuyItem('reveal_path', 0, isRealMoney: true)),
                        ),
                        
                        const SizedBox(height: 20),
                        _buildSectionTitle("GET LIVES"),
                        _buildSimpleActionRow(
                          context,
                          icon: Icons.play_circle_fill,
                          title: "WATCH VIDEO",
                          subtitle: "${3 - state.videosWatched} left today",
                          price: "FREE",
                          onPressed: state.videosWatched < 3 && state.lives < state.maxLives
                            ? () => context.read<HomeBloc>().add(WatchVideoForLife())
                            : null,
                        ),
                        _buildLifePack(context, 1, 0.29),
                        _buildLifePack(context, 5, 0.99),
                        _buildSimpleActionRow(
                          context,
                          icon: Icons.all_inclusive,
                          title: "UNLIMITED",
                          subtitle: "24 hours of lives",
                          price: "\$4.99",
                          onPressed: () {},
                        ),

                        const SizedBox(height: 20),
                        _buildSectionTitle("PUZZLE PACKS"),
                        _buildPuzzlePack(context, 10, 0.99, isDaily: true, state: state),
                        _buildPuzzlePack(context, 50, 3.99),
                        _buildPuzzlePack(context, 100, 6.99),
                        _buildPuzzlePack(context, 1000, 49.99),

                        const SizedBox(height: 20),
                        _buildSectionTitle("EXTRAS"),
                        _buildSimpleActionRow(
                          context,
                          icon: Icons.block,
                          title: "REMOVE ADS",
                          subtitle: "No more interruptions",
                          price: "\$1.99",
                          onPressed: () => context.read<HomeBloc>().add(BuyNoAds()),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(width: 40, height: 2, color: Colors.black12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black26, fontSize: 12)),
          ),
          Expanded(child: Container(height: 2, color: Colors.black12)),
        ],
      ),
    );
  }

  Widget _buildCurrencyHeader(int puzzles) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.candyBlue.withValues(alpha: 0.3), width: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGlossyPuzzleIcon(size: 30),
          const SizedBox(width: 10),
          Text(
            "$puzzles PUZZLES",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.candyPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlossyPuzzleIcon({double size = 24}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.extension, color: Colors.orangeAccent, size: size),
        Positioned(
          top: size * 0.15,
          left: size * 0.15,
          child: Container(
            width: size * 0.4,
            height: size * 0.2,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(size),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShopItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required int count,
    required int puzzleCost,
    required double moneyCost,
    required VoidCallback onBuyPuzzles,
    required VoidCallback onBuyMoney,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.candyBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: AppColors.candyBlue, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text(description, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                    Text("OWNED: $count", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.candyPurple)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CandyButton(
                  height: 40,
                  borderRadius: 15,
                  color: AppColors.candyYellow,
                  darkColor: AppColors.candyYellowDark,
                  onPressed: onBuyPuzzles,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGlossyPuzzleIcon(size: 16),
                      const SizedBox(width: 4),
                      Text("$puzzleCost", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CandyButton(
                  height: 40,
                  borderRadius: 15,
                  color: AppColors.candyGreen,
                  darkColor: AppColors.candyGreenDark,
                  onPressed: onBuyMoney,
                  child: Text("\$$moneyCost", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleActionRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String price,
    required VoidCallback? onPressed,
    Widget? trailingOverride,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.candyBlue, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          trailingOverride ?? CandyButton(
            width: 80,
            height: 40,
            borderRadius: 15,
            color: AppColors.candyGreen,
            darkColor: AppColors.candyGreenDark,
            onPressed: onPressed,
            child: Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildLifePack(BuildContext context, int count, double price) {
    return _buildSimpleActionRow(
      context,
      icon: Icons.favorite,
      title: "REFILL $count ${count > 1 ? 'LIVES' : 'LIFE'}",
      subtitle: "Get back in the game!",
      price: "\$$price",
      onPressed: () => context.read<HomeBloc>().add(BuyLives(count)),
    );
  }

  Widget _buildPuzzlePack(BuildContext context, int count, double price, {bool isDaily = false, HomeState? state}) {
    if (isDaily && state != null) {
      bool canClaim = state.lastDailyPuzzleAt == null || 
                      DateTime.now().difference(state.lastDailyPuzzleAt!).inHours >= 24;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
        child: Row(
          children: [
            _buildGlossyPuzzleIcon(size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$count PUZZLES", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  const Text("Daily Reward", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            CandyButton(
              width: 70,
              height: 40,
              borderRadius: 15,
              color: AppColors.candyBlue,
              darkColor: AppColors.candyBlueDark,
              onPressed: canClaim ? () => context.read<HomeBloc>().add(ClaimDailyPuzzle()) : null,
              child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 8),
            CandyButton(
              width: 70,
              height: 40,
              borderRadius: 15,
              color: AppColors.candyGreen,
              darkColor: AppColors.candyGreenDark,
              onPressed: () => context.read<HomeBloc>().add(BuyPuzzlePack(count, price)),
              child: Text("\$$price", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
            ),
          ],
        ),
      );
    }

    return _buildSimpleActionRow(
      context,
      icon: Icons.extension,
      title: "$count PUZZLES",
      subtitle: "Puzzle pack",
      price: "\$$price",
      onPressed: () => context.read<HomeBloc>().add(BuyPuzzlePack(count, price)),
    );
  }
}
