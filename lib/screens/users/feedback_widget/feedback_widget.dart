/*
*  feedback_widget.dart
*  AMCS-additional-pages
*
*  Created by InstaSoft Inc.
*  Copyright © 2018 InstaSoft Inc. All rights reserved.
    */

import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../../../frameworks/magento/services/magento.dart';
import '../../../generated/l10n.dart';
import '../../../values/values.dart';

class FeedbackWidget extends StatefulWidget {
  @override
  _FeedbackWidgetState createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  final _formKey = GlobalKey<FormState>();

  String? subject = '';
  String? name = '';
  String? mobileNo = '';
  String? feedback = '';

  void _onPressed() async {
    print("pre");
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var success =
          await MagentoApi().submitFeedback(name, mobileNo, subject, feedback);
      if (success) {
        _formKey.currentState!.reset();
        //show dialog
        Tools.showSnackBar(ScaffoldMessenger.of(context), S.of(context).feedback_submit);
        Future.delayed(
            const Duration(seconds: 2), () => Navigator.of(context).pop());
      } else {
        Tools.showSnackBar(
            ScaffoldMessenger.of(context), S.of(context).feedback_submit_error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        title: Text(
          S.of(context).feedback,
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
      body: Form(
        key: _formKey,
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            // color: Color.fromARGB(255, 255, 255, 255),
          ),
          child: ListView(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                //height: 375,
                margin: const EdgeInsets.all(10),
                decoration:  BoxDecoration(
                //  color: Theme.of(context).accentColor,
                  boxShadow: [
                    Shadows.primaryShadow,
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 390,
                      //height: 90,
                      margin: const EdgeInsets.all(5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).name,
                            textAlign: TextAlign.left,
                            style:  TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              // fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                //margin: EdgeInsets.only(left: 13, top: 14),
                                child: Opacity(
                                  opacity: 0.66138,
                                  child: TextFormField(
                                    onSaved: (newValue) => name = newValue,
                                    validator: (value) => value!.isEmpty
                                        ? S.of(context).Cannot_be_blank
                                        : null,
                                    decoration: InputDecoration(
                                      hintText: S.of(context).enter_your_name,
                                      hintStyle: const TextStyle(
                                          color: Colors.black54),
                                      contentPadding: const EdgeInsets.all(0),
                                      border: InputBorder.none,
                                      fillColor: AppColors.secondaryElement,
                                      filled: true,
                                    ),
                                    style:  TextStyle(
                                      color: Colors.black,
                                      // fontFamily: "Poppins",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                    autocorrect: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 390,
                      //height: 90,
                      margin: const EdgeInsets.all(5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).phone,
                            textAlign: TextAlign.left,
                            style:  TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              // fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                //margin: EdgeInsets.only(left: 13, top: 14),
                                child: Opacity(
                                  opacity: 0.66138,
                                  child: TextFormField(
                                    keyboardType: TextInputType.phone,
                                    onSaved: (newValue) => mobileNo = newValue,
                                    validator: (value) => value!.isEmpty
                                        ? S.of(context).Cannot_be_blank
                                        : null,
                                    decoration: InputDecoration(
                                      hintText: S.of(context).phone_number,
                                      hintStyle: const TextStyle(
                                          color: Colors.black54),
                                      contentPadding: const EdgeInsets.all(0),
                                      border: InputBorder.none,
                                      fillColor: AppColors.secondaryElement,
                                      filled: true,
                                    ),
                                    style:  TextStyle(
                                     color: Colors.black,
                                      // fontFamily: "Poppins",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                    autocorrect: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 390,
                      //height: 90,
                      margin: const EdgeInsets.all(5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).subject,
                            textAlign: TextAlign.left,
                            style:  TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              // fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                //margin: EdgeInsets.only(left: 13, top: 14),
                                child: Opacity(
                                  opacity: 0.66138,
                                  child: TextFormField(
                                    onSaved: (newValue) => subject = newValue,
                                    validator: (value) => value!.isEmpty
                                        ? S.of(context).Cannot_be_blank
                                        : null,
                                    decoration: InputDecoration(
                                      hintText: S.of(context).subject_desc,
                                      hintStyle: const TextStyle(
                                          color: Colors.black54),
                                      contentPadding: const EdgeInsets.all(0),
                                      border: InputBorder.none,
                                      fillColor: AppColors.secondaryElement,
                                      filled: true,
                                    ),
                                    style:  TextStyle(
                                    color: Colors.black,
                                      // fontFamily: "Poppins",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                    autocorrect: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 390,
                      //height: 90,
                      margin: const EdgeInsets.all(5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).feedback,
                            textAlign: TextAlign.left,
                            style:  TextStyle(
                             color: Theme.of(context).colorScheme.secondary,
                              // fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                //margin: EdgeInsets.only(left: 13, top: 14),
                                child: Opacity(
                                  opacity: 0.66138,
                                  child: TextFormField(
                                    maxLines: 10,
                                    onSaved: (newValue) => feedback = newValue,
                                    validator: (value) => value!.isEmpty
                                        ? S.of(context).Cannot_be_blank
                                        : null,
                                    decoration: InputDecoration(
                                      hintText: S.of(context).feedback_desc,
                                      hintStyle: const TextStyle(
                                          color: Colors.black54),
                                      contentPadding: const EdgeInsets.all(0),
                                      border: InputBorder.none,
                                      fillColor: AppColors.secondaryElement,
                                      filled: true,
                                    ),
                                    style:  TextStyle(
                                      color: Colors.black,
                                      // fontFamily: "Poppins",
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                    autocorrect: false,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    //Spacer(),
                    // const SizedBox(
                    //   height: 15,
                    // ),
                    Center(
                      child: TextButton(
                        onPressed: _onPressed,
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              side: BorderSide(
                                  color: Theme.of(context).primaryColor)),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(15),
                        ),
                        child: Text(
                          S.of(context).submit.toUpperCase(),
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
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
      ),
    );
  }
}
