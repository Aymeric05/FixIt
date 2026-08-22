import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/home_bloc.dart';
import 'candy_dialog.dart';
import '../../../../core/widgets/candy_button.dart';
import '../../../../core/theme/app_colors.dart';

class SocialDialog extends StatefulWidget {
  const SocialDialog({super.key});

  @override
  State<SocialDialog> createState() => _SocialDialogState();
}

class _SocialDialogState extends State<SocialDialog> {
  late TextEditingController _usernameController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<HomeBloc>().state;
    _usernameController = TextEditingController(text: state.username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CandyDialog(
      title: 'PROFILE',
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              'YOUR UNIQUE USERNAME:',
              style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.candyPurple, fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.candyBlue, fontSize: 20),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: AppColors.candyBlue, width: 3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: AppColors.candyBlue, width: 3),
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<HomeBloc>().add(UpdateUsername(value));
                }
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'FIND FRIENDS:',
              style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.candyPink, fontSize: 18),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: AppColors.candyPink, size: 30),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: AppColors.candyPink, width: 3),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: AppColors.candyPink, width: 3),
                ),
                hintText: 'Search friends...',
              ),
            ),
            const SizedBox(height: 30),
            CandyButton(
              width: 180,
              height: 55,
              color: AppColors.candyPink,
              darkColor: AppColors.candyPinkDark,
              onPressed: () {
                if (_searchController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.candyPink,
                      content: Text(
                        'SEARCHING FOR ${_searchController.text.toUpperCase()}...',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                'SEARCH',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
