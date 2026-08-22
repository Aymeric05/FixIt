import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import 'candy_dialog.dart';
import '../../../../core/widgets/candy_button.dart';
import '../../../../core/theme/app_colors.dart';

class NoAdsDialog extends StatelessWidget {
  const NoAdsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CandyDialog(
      title: 'NO ADS',
      content: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.candyPink.withOpacity(0.3), width: 4),
            ),
            child: const Icon(Icons.block, size: 80, color: AppColors.candyPink),
          ),
          const SizedBox(height: 25),
          const Text(
            'ENJOY THE GAME WITHOUT ANY INTERRUPTIONS!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: AppColors.candyPurple, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 35),
          CandyButton(
            width: 220,
            height: 65,
            color: AppColors.candyGreen,
            darkColor: AppColors.candyGreenDark,
            onPressed: () {
              context.read<HomeBloc>().add(BuyNoAds());
              Navigator.of(context).pop();
            },
            child: const Text(
              'BUY FOR \$1.99',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
