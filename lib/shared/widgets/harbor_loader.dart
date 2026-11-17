import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HarborLoader extends StatelessWidget {
  const HarborLoader({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Loading',
    liveRegion: true,
    child: Lottie.asset(
      'assets/animations/crystal_water_droplet_loader.json',
      width: size,
      height: size,
      fit: BoxFit.contain,
      repeat: true,
    ),
  );
}
