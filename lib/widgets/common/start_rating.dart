import 'package:flutter/material.dart';

import '../../common/constants.dart';

typedef void RatingChangeCallback(double rating);

class SmoothStarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback? onRatingChanged;
  final Color? color;
  final Color? borderColor;
  final double? size;
  final bool allowHalfRating;
  final double spacing;
  final Widget? label;

  SmoothStarRating({
    this.starCount = 5,
    this.rating = 0.0,
    this.onRatingChanged,
    this.color,
    this.borderColor,
    this.size,
    this.spacing = 0.0,
    this.label,
    this.allowHalfRating = true,
  }) {
    assert(rating != null);
  }

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = Icon(
        Icons.star_border,
        color: borderColor ?? kColorRatingStar,
        size: size ?? 18.0,
      );
    } else if (index > rating - (allowHalfRating ? 0.5 : 1.0) && index < rating) {
      icon = Icon(
        Icons.star_half,
        color: color ?? kColorRatingStar,
        size: size ?? 18.0,
      );
    } else {
      icon = Icon(
        Icons.star,
        color: color ?? kColorRatingStar,
        size: size ?? 18.0,
      );
    }

    if (onRatingChanged == null) {
      return icon;
    }

    return GestureDetector(
      child: icon,
      onTap: () {
        if (onRatingChanged != null) {
          onRatingChanged!(index + 1.0);
        }
      },
      onHorizontalDragUpdate: (dragDetails) {
        RenderBox box = context.findRenderObject() as RenderBox;
        final _pos = box.globalToLocal(dragDetails.globalPosition);
        final i = _pos.dx / size!;
        var newRating = allowHalfRating ? i : i.round().toDouble();
        if (newRating > starCount) {
          newRating = starCount.toDouble();
        }
        if (newRating < 0) {
          newRating = 0.0;
        }
        if (onRatingChanged != null) {
          onRatingChanged!(newRating);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.start,
          spacing: spacing,
          children: List.generate(starCount, (index) => buildStar(context, index)),
        ),
        const SizedBox(width: 4),
        label!,
      ],
    );
  }
}
