import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomCheckBox extends StatelessWidget {
  final bool value;
  final bool isError;
  final ValueChanged<bool> onChanged;

  const CustomCheckBox({
    super.key,
    required this.value,
    required this.isError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: value
            ? SvgPicture.asset('assets/icons/checkbox_on.svg',
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn))
            : SvgPicture.asset('assets/icons/checkbox_off.svg',
            colorFilter: ColorFilter.mode(
                isError ? Colors.red : Colors.black,
                BlendMode.srcIn)),
      ),
    );
  }
}