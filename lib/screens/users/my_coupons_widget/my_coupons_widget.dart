/*
*  my_coupons_widget.dart
*  AMCS-additional-pages
*
*  Created by InstaSoft Inc.
*  Copyright © 2018 InstaSoft Inc. All rights reserved.
    */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants/loading.dart';
import '../../../frameworks/magento/services/magento.dart';
import '../../../generated/l10n.dart';
import '../../../models/app_model.dart';

class MyCouponsWidget extends StatefulWidget {
  @override
  _MyCouponsWidgetState createState() => _MyCouponsWidgetState();
}

class _MyCouponsWidgetState extends State<MyCouponsWidget> {
  List<Map?>? couponCodes;

  @override
  void initState() {
    super.initState();
    _getCoupons();
  }

  _getCoupons() {
    String lang = Provider.of<AppModel>(context, listen: false).langCode ?? "en";
    MagentoApi().getCouponCodes(lang).then(
      (value) {
        setState(() {
          couponCodes = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).mycoupons,
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
      body: couponCodes == null
          ? Container(height: 80, child: kLoadingWidget(context))
          : couponCodes!.isEmpty
              ? Center(
                  child: Container(
                    child: const Text('No data to show'),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(left: 13, top: 30, right: 13),
                  child: ListView.separated(
                      itemBuilder: (context, index) => ListTile(
                            tileColor: Theme.of(context).colorScheme.surface,
                            title: Text(couponCodes![index]!['code']),
                            subtitle: Text('Times Used: ${couponCodes![index]!['times_used']}'),
                          ),
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: couponCodes!.length),
                ),
    );
  }
}
