import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class CorsImage extends StatelessWidget {
  final String url;
  final BoxFit? fit;
  final Widget? errorWidget;

  const CorsImage({super.key, required this.url, this.fit, this.errorWidget});

  @override
  Widget build(BuildContext context) {
    final viewId = 'img_${identityHashCode(this)}';
    html.document.getElementById(viewId)?.remove();
    final imgElement = html.ImageElement(src: url)
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = fit == BoxFit.cover ? 'cover' : 'contain'
      ..style.borderRadius = '4px'
      ..onError.first.then((_) {
        final el = html.document.getElementById(viewId);
        if (el != null) el.style.display = 'none';
      });
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => imgElement,
    );
    return HtmlElementView(viewType: viewId);
  }
}
