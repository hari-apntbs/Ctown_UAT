import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../common/countdown_timer.dart';

class HeaderView extends StatelessWidget {
  final String? headerText;
  final VoidCallback? callback;
  final bool showSeeAll;
  final bool showCountdown;
  final Duration countdownDuration;
  final double margin;

  HeaderView({
    this.headerText,
    this.showSeeAll = false,
    Key? key,
    this.callback,
    this.margin = 10.0,
    this.showCountdown = false,
    this.countdownDuration = const Duration(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
       // width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
        margin: EdgeInsets.only(top: margin),
        padding: const EdgeInsets.only(
          left: 5.0,
          top: 5.0,
          right: 5.0,
          bottom: 10.0,
        ),
        child: Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    headerText ?? '',
                    style: const TextStyle(
                       // color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                    // style: Theme.of(context).textTheme.headline6,
                  ),
                  if (showCountdown)
                    Row(
                      children: [
                        Text(
                          S.of(context).endsIn("").toUpperCase(),

                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                color: Theme.of(context)
                                    .colorScheme.secondary
                                    .withOpacity(0.8),
                            fontSize: 12,
                              )
                              .apply(fontSizeFactor: 0.4),
                        ),
                        CountDownTimer(countdownDuration),
                      ],
                    ),
                ],
              ),
            ),
            if (showSeeAll)
              InkResponse(
                onTap: callback,
                child: Text(
                  S.of(context).seeAll,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Theme.of(context).primaryColor,fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
