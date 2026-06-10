import 'package:flutter/material.dart';
import 'package:qdone/core/theme/app_colors.dart';
import 'package:qdone/core/theme/app_fonts.dart';

class QDoneBrandText extends StatelessWidget {
  const QDoneBrandText({
    super.key,
    this.fontSize = 23,
    this.color,
    this.letterSpacing = 5.2,
    this.fontWeight = FontWeight.w600,
  });

  final double fontSize;
  final Color? color;
  final double letterSpacing;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      'QDONE',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color ?? AppColors.foreground(context),
        decoration: TextDecoration.none,
        fontFamily: AppFonts.brand,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      ),
    );
  }
}

class QDoneBrandRichText extends StatelessWidget {
  const QDoneBrandRichText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = DefaultTextStyle.of(context).style.merge(style);
    final matches = RegExp(r'\b(?:QDone|QDONE)\b').allMatches(text);
    final spans = <InlineSpan>[];
    var offset = 0;
    for (final match in matches) {
      if (match.start > offset) {
        spans.add(
          TextSpan(
            text: text.substring(offset, match.start),
            style: effectiveStyle,
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: effectiveStyle.copyWith(fontFamily: AppFonts.brand),
        ),
      );
      offset = match.end;
    }
    if (offset < text.length) {
      spans.add(TextSpan(text: text.substring(offset), style: effectiveStyle));
    }
    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
