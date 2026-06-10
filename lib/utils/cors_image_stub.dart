import 'package:flutter/material.dart';

class CorsImage extends StatelessWidget {
  final String url;
  final BoxFit? fit;
  final Widget? errorWidget;

  const CorsImage({
    super.key,
    required this.url,
    this.fit,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => errorWidget ?? SizedBox.shrink(),
    );
  }
}
