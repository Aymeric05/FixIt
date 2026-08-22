import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import 'candy_dialog.dart';
import '../../../../core/widgets/candy_button.dart';
import '../../../../core/theme/app_colors.dart';

class LivesStoreDialog extends StatelessWidget {
  const LivesStoreDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return CandyDialog(
          title: 'GET LIVES',
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 450),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildOption(
                    context,
                    title: 'Watch Video',
                    subtitle: '${3 - state.videosWatched} left today',
                    icon: Icons.play_circle_fill,
                    color: AppColors.candyBlue,
                    darkColor: AppColors.candyBlueDark,
                    price: 'FREE',
                    onPressed: state.videosWatched < 3 && state.lives < state.maxLives
                        ? () => context.read<HomeBloc>().add(WatchVideoForLife())
                        : null,
                  ),
                  _buildOption(
                    context,
                    title: 'Refill 1 Life',
                    subtitle: 'One more try!',
                    heartCount: 1,
                    color: AppColors.candyYellow,
                    darkColor: AppColors.candyYellowDark,
                    price: '\$0.29',
                    onPressed: () => context.read<HomeBloc>().add(const BuyLives(1)),
                  ),
                  _buildOption(
                    context,
                    title: 'Refill 2 Lives',
                    subtitle: 'Double the fun',
                    heartCount: 2,
                    color: AppColors.candyOrange,
                    darkColor: AppColors.candyOrangeDark,
                    price: '\$0.49',
                    onPressed: () => context.read<HomeBloc>().add(const BuyLives(2)),
                  ),
                  _buildOption(
                    context,
                    title: 'Refill 5 Lives',
                    subtitle: 'Full refill',
                    heartCount: 5,
                    color: AppColors.candyPink,
                    darkColor: AppColors.candyPinkDark,
                    price: '\$0.99',
                    onPressed: () => context.read<HomeBloc>().add(const BuyLives(5)),
                  ),
                  _buildOption(
                    context,
                    title: 'Unlimited',
                    subtitle: '24 hours of fun!',
                    heartCount: -1, // infinity
                    color: AppColors.candyPurple,
                    darkColor: AppColors.candyPurpleDark,
                    price: '\$4.99',
                    onPressed: () {
                      // Mock unlimited logic
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    IconData? icon,
    int? heartCount,
    required Color color,
    required Color darkColor,
    required String price,
    required VoidCallback? onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 3),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Center(
              child: heartCount != null
                  ? _buildJuicyHeartStack(heartCount)
                  : Icon(icon, color: color, size: 40),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: color,
                      height: 1.1),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      height: 1.1),
                ),
              ],
            ),
          ),
          CandyButton(
            width: 75,
            height: 40,
            borderRadius: 20,
            depth: 4,
            color: onPressed == null ? Colors.grey : color,
            darkColor: onPressed == null ? Colors.grey.shade700 : darkColor,
            onPressed: onPressed ?? () {},
            child: Text(
              price,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJuicyHeartStack(int count) {
    if (count == -1) {
      return Stack(
        alignment: Alignment.center,
        children: [
          _buildSingleHeart(size: 45),
          const Icon(Icons.all_inclusive, color: Colors.white, size: 24),
        ],
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: List.generate(count.clamp(1, 5), (index) {
        double offset = index * 4.0;
        return Positioned(
          left: 5 + offset,
          top: 5 + offset,
          child: _buildSingleHeart(size: 35),
        );
      }),
    );
  }

  Widget _buildSingleHeart({double size = 40}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.favorite, color: Colors.black26, size: size + 4),
        ShaderMask(
          shaderCallback: (bounds) => const RadialGradient(
            center: Alignment(-0.3, -0.3),
            colors: [Colors.white, Colors.red, Color(0xFF8B0000)],
            radius: 0.8,
          ).createShader(bounds),
          child: Icon(Icons.favorite, color: Colors.white, size: size),
        ),
      ],
    );
  }
}
