import 'package:flutter/material.dart';

import '../../../utils/utils.dart';

class BottomSheetInfo extends StatelessWidget {
  final Widget topIcon;
  final String? title;
  final String? description;
  final Widget? bottomWidget;
  const BottomSheetInfo({
    super.key,
    required this.topIcon,
    this.title,
    this.description,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                topIcon,
                if (title?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 32),
                  Text(title!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'poppins',
                          color: K2Colors.materialDarkBlue[500])),
                  const SizedBox(height: 24),
                ],
                if (description?.isNotEmpty ?? false) ...[
                  Text(
                    description!,
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'poppins',
                        color: K2Colors.materialDarkBlue[400]),
                  ),
                ],
                const SizedBox(height: 20),
                bottomWidget ?? const SizedBox.shrink(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
