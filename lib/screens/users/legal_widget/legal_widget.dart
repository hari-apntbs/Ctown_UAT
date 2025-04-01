/*
*  legal_widget.dart
*  AMCS-additional-pages
*
*  Created by InstaSoft Inc.
*  Copyright © 2018 InstaSoft Inc. All rights reserved.
    */

import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../../values/values.dart';

class LegalWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).legals,
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          // color: Color.fromARGB(255, 255, 255, 255),
        ),
        padding: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              // width: 334,
              height: 45,
              margin: const EdgeInsets.only(top: 0, right: 0, left: 0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: Radii.k5pxRadius,
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      color: Colors.black54,
                      icon: const Icon(Icons.visibility),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => Navigator.of(context).pushNamed('/terms_condition', arguments: '26'),
                      // onTap: () {
                      //   printLog("langCode12345");
                      //  printLog(_getPrefs());
                      //   if(_getPrefs()== "en") {
                      //     Navigator.of(context).pushNamed(
                      //         '/terms_condition', arguments: '26');
                      //   }
                      //   else if(_getPrefs()== "ar") {
                      //     Navigator.of(context).pushNamed(
                      //         '/terms_condition', arguments: '27');
                      //   }
                      // },
                      child: Text(
                        S.of(context).TermsConditions,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Colors.black,
                          // fontFamily: "raleway",
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              //width: 334,
              height: 45,
              margin: const EdgeInsets.only(top: 5, right: 0, left: 0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: Radii.k5pxRadius,
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      color: Colors.black54,
                      icon: const Icon(Icons.visibility),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => Navigator.of(context).pushNamed('/privacy_policy', arguments: '24'),
                      child: Text(
                        S.of(context).PrivacyAndTerm,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Colors.black,
                          // fontFamily: "raleway",
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              // width: 334,
              height: 45,
              margin: const EdgeInsets.only(top: 5, right: 0, left: 0),
              //margin: EdgeInsets.only(top: 10, right: 20,left:20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: Radii.k5pxRadius,
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      color: Colors.black54,
                      icon: const Icon(Icons.visibility),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => Navigator.of(context).pushNamed('/delivery_policy', arguments: '28'),
                      child: Text(
                        S.of(context).DeliveryPolicy,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Colors.black,
                          // fontFamily: "raleway",
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              //  width: 334,
              height: 45,
              margin: const EdgeInsets.only(top: 5, right: 0, left: 0),
              //  margin: EdgeInsets.only(top: 10, right: 20,left:20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: Radii.k5pxRadius,
              ),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      color: Colors.black54,
                      icon: const Icon(Icons.visibility),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => Navigator.of(context).pushNamed('/payment_policy', arguments: '32'),
                      child: Text(
                        S.of(context).PaymentPolicy,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Colors.black,
                          // fontFamily: "raleway",
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              // width: 334,
              height: 45,
              margin: const EdgeInsets.only(top: 5, right: 0, left: 0),
              // margin: EdgeInsets.only(top: 10, right: 20,left:20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: Radii.k5pxRadius,
              ),
              child: Row(
                children: [
                  Container(
                    // width: 25,
                    // height: 25,
                    margin: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      color: Colors.black54,
                      icon: const Icon(Icons.visibility),
                      onPressed: () {},
                      //tooltip: 'Increase volume by 10',
                      // onPressed: () {
                      //   setState(() {
                      //     _volume += 10;
                      //   });
                      // },
                    ),
                    // child: Image.asset(
                    //   "assets/images/minus.png",
                    //   fit: BoxFit.none,
                    // ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => Navigator.of(context).pushNamed('/return_policy', arguments: '28'),
                      child: Text(
                        S.of(context).ReturnCancellationPolicy,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Colors.black,
                          // fontFamily: "raleway",
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _getPrefs() async{
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final _langCode=prefs.getString('language');
  //   printLog("language1");
  //   printLog(_langCode);
  // }
}
