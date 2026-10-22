import 'package:flutter/material.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';

class WorkoutHero extends StatelessWidget {
  const WorkoutHero({
    super.key,
    required this.workout,
  });

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final canPop = Navigator.of(context).canPop();

    return SizedBox(
      height: screenHeight * 0.42,
      width: double.infinity,
      child: Stack(
        children: [
          const _HeroImage(),
          const _HeroGradient(),
          if (canPop) const _HeroBackButton(),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/workoutPicture2.png'),
        ),
      ),
    );
  }
}

class _HeroGradient extends StatelessWidget {
  const _HeroGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black26,
            Colors.transparent,
            Colors.black54,
          ],
        ),
      ),
    );
  }
}

class _HeroBackButton extends StatelessWidget {
  const _HeroBackButton();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      child: SafeArea(
        child: Material(
          color: Colors.black38,
          shape: const CircleBorder(),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
        ),
      ),
    );
  }
}
