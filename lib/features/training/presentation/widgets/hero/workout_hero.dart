import 'package:flutter/material.dart';
import 'package:muevete/features/training/domain/entities/workout.dart';

class WorkoutHero extends StatelessWidget {
  final Workout workout;

  const WorkoutHero({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return SizedBox(
      height: screenHeight * 0.42,
      width: double.infinity,
      child: Stack(
        children: [

          _HeroImage(),

          _HeroGradient(),

          _HeroBackButton(),

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
      decoration: BoxDecoration(
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
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back)
        ),
      ),
    );
  }
}
