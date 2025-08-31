import 'package:flutter/widgets.dart';
import '../style/app_colors.dart';

class CharacterAvatar extends StatelessWidget {
  final int characterType;
  final double size;
  final bool showBackground;
  final Color? backgroundColor;

  const CharacterAvatar({
    super.key, 
    required this.characterType, 
    this.size = 40,
    this.showBackground = true,
    this.backgroundColor,
  });

  String _assetPathForType(int type) {
    // type은 1~9 사이 정수라고 가정
    final clamped = type.clamp(1, 9);
    return 'lib/interface/asset/character$clamped.png';
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = Transform.translate(
      offset: const Offset(0, 6),
      child: Image.asset(
        _assetPathForType(characterType),
        width: size+5,
      //   height: size+5,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: showBackground ? AppColors.primaryLight : null,
          );
        },
      ),
    );

    if (!showBackground) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(child: imageWidget),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryLightest,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Center(child: imageWidget),
      ),
    );
  }
}
