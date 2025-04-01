/*
*  help_center_widget.dart
*  AMCS-additional-pages
*
*  Created by InstaSoft Inc.
*  Copyright © 2018 InstaSoft Inc. All rights reserved.
    */

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../frameworks/magento/services/magento.dart';
import '../../../generated/l10n.dart';

class HelpCenterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).helpSupport,
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
      body: FutureBuilder<Map<String, dynamic>?>(
          future: MagentoApi().getContactDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Container(
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(
                  // color: Color.fromARGB(255, 255, 255, 255),
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.cover,
                    ),
                  ),

                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                        SizedBox(width:30),
                      Container(
                        child: Text(
                          S.of(context).address,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            
                            // fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        width: 220,
                        child: Center(
                            child: Html(
                          data: snapshot.data!['address'],
                          style: {
                            'p': Style(
                              color: Colors.red,
                              // fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              fontSize: FontSize.medium,
                            )
                          },
                        )),
                      ),
                      //                       ),
                    ],
                  ),
                  Row(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                         SizedBox(width:30),
                      Container(
                        // margin: EdgeInsets.only(right:5),
                        child: Text(
                          S.of(context).email,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                           
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    SizedBox(width:10),
             

                      Container(
                        //  margin: EdgeInsets.only(right:15),
                        // width: 220,
                        child: TextButton(
                           onPressed: () async{await launch("mailto:${snapshot.data!['email']}");},
                                                  child: Text(
                            
                              
                            snapshot.data!['email'],
                            //"info@ahmarket.com",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                               color: Colors.blue,
                              // color: Theme.of(context).accentColor,
                              // fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                        SizedBox(width:30),
                      Container(
                        // margin: EdgeInsets.only(right:5),
                        child: Text(
                          S.of(context).phone,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                           
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
             
  SizedBox(width:10),
                      Container(
                        //  margin: EdgeInsets.only(right:15),
                        // width: 220,
                        child: TextButton(
                          onPressed: () async{await launch("tel://${snapshot.data!['mobile_no']}");},
                                                  child: Text(
                            snapshot.data!['mobile_no'],
                            //"info@ahmarket.com",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              // color: Theme.of(context).accentColor,
                               color: Colors.blue,
                              // fontFamily: "Poppins",
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  //     Container(
                  //       // height: 400,
                  //       margin: const EdgeInsets.all(10),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Align(
                  //             alignment: Alignment.topCenter,
                  //             child: Container(
                  //               height: 100.0,
                  //               width: 200,

                  //               decoration: BoxDecoration(
                  //                 // color: Colors.red,
                  //                 image: DecorationImage(
                  //                     image: AssetImage(
                  //                       "assets/images/logo.png",
                  //                     ),
                  //                     fit: BoxFit.cover),
                  //               ),
                  //               // child: Image.asset(kLogo,
                  //               //     width: 300,
                  //               //     fit: BoxFit.fitHeight)
                  //             ),
                  //           ),
                  //           Container(
                  //             // height: 300,
                  //             margin: const EdgeInsets.only(top: 10),
                  //             decoration: const BoxDecoration(
                  //               // color: AppColors.secondaryBackground,
                  //               borderRadius: BorderRadius.all(Radius.circular(7)),
                  //             ),
                  //             child: Column(
                  //               crossAxisAlignment: CrossAxisAlignment.stretch,
                  //               children: [
                  //                 Container(
                  //                   height: 137,
                  //                   margin: const EdgeInsets.only(
                  //                       left: 10, top: 0, right: 10),
                  //                   child: Row(
                  //                     crossAxisAlignment:
                  //                         CrossAxisAlignment.stretch,
                  //                     children: [
                  //                       Align(
                  //                         alignment: Alignment.topLeft,
                  //                         child: Container(
                  //                           margin: const EdgeInsets.only(top: 57),
                  //                           child: Text(
                  //                             S.of(context).address,
                  //                             textAlign: TextAlign.left,
                  //                             style:  TextStyle(
                  //                               color: Theme.of(context).accentColor,
                  //                               // fontFamily: "Poppins",
                  //                               fontWeight: FontWeight.w600,
                  //                               fontSize: 16,
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                       const Spacer(),
                  //                       Align(
                  //                         alignment: Alignment.topLeft,
                  // child: Container(
                  //   width: 220,
                  //   child: Center(
                  //       child: Html(
                  //     data: snapshot.data['address'],
                  //     style: {
                  //       'p': Style(
                  //         color: Colors.red,
                  //         // fontFamily: "Poppins",
                  //         fontWeight: FontWeight.w400,
                  //         fontSize: FontSize.medium,
                  //       )
                  //     },
                  //   )),
                  //   // Text(
                  //   //   snapshot.data['address'],
                  //   //   // "\nRumailah Showroom, A&H Market, \nNear to Honda Showroom,\nRumaila -2, A&H Market,\nUnited Arab Emirates\n",
                  //   //   textAlign: TextAlign.left,
                  //   //   style: const TextStyle(
                  //   //     color: AppColors.primaryText,
                  //   //     fontFamily: "Poppins",
                  //   //     fontWeight: FontWeight.w400,
                  //   //     fontSize: 16,
                  //   //   ),
                  //   // ),
                  // ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ),
                  //                 Container(
                  //                   height: 27,
                  //                   // margin: const EdgeInsets.only(
                  //                   //     left: 10, top: 3, right: 10),
                  //                   child: Row(
                  //                     crossAxisAlignment:
                  //                         CrossAxisAlignment.start,
                  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //                     children: [
                  //                       Container(
                  //                         margin: const EdgeInsets.only(top: 2),
                  //                         child: Text(
                  //                           S.of(context).email,
                  //                           textAlign: TextAlign.left,
                  //                           style:  TextStyle(
                  //                            color: Theme.of(context).accentColor,
                  //                             // fontFamily: "Poppins",
                  //                             fontWeight: FontWeight.w600,
                  //                             fontSize: 16,
                  //                           ),
                  //                         ),
                  //                       ),
                  //                       // const Spacer(),

                  //                       Container(
                  //                         width: 220,
                  //                         child: Text(
                  //                           snapshot.data['email'],
                  //                           //"info@ahmarket.com",
                  //                           textAlign: TextAlign.left,
                  //                           style:  TextStyle(
                  //                            color: Theme.of(context).accentColor,
                  //                             // fontFamily: "Poppins",
                  //                             fontWeight: FontWeight.w400,
                  //                             fontSize: 15,
                  //                           ),
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   ),
                  //                 ),
                  //                 Container(
                  //                   height: 100,
                  //                   margin: const EdgeInsets.only(
                  //                       left: 10, top: 10, right: 10),
                  //                   child: Row(
                  //                     crossAxisAlignment:
                  //                         CrossAxisAlignment.start,
                  //                     children: [
                  //                       Text(
                  //                         S.of(context).phone,
                  //                         textAlign: TextAlign.left,
                  //                         style:  TextStyle(
                  //                     color: Theme.of(context).accentColor,
                  //                           // fontFamily: "Poppins",
                  //                           fontWeight: FontWeight.w600,
                  //                           fontSize: 16,
                  //                         ),
                  //                       ),
                  //                       const Spacer(),
                  //                       // Align(
                  //                       //   alignment: Alignment.topLeft,
                  //                       //   child: Container(
                  //                       //     width: 230,
                  //                       //     //  margin: EdgeInsets.only(left: 25, top: 1),
                  //                       //     child: Text(
                  //                       //       snapshot.data['mobile_no'],
                  //                       //       //"(+971) 67478900",
                  //                       //       textAlign: TextAlign.left,
                  //                       //       style: const TextStyle(
                  //                       //         color: AppColors.primaryText,
                  //                       //         // fontFamily: "Poppins",
                  //                       //         fontWeight: FontWeight.w400,
                  //                       //         fontSize: 15,
                  //                       //       ),
                  //                       //     ),
                  //                       //   ),
                  //                       // ),
                  //                         Container(
                  //                           width: 230,
                  //                            child: FlatButton(
                  // onPressed: () async{await launch("tel://${snapshot.data['mobile_no']}");},
                  //                         child: Text(
                  //                             snapshot.data['mobile_no'],
                  //                             //"(+971) 67478900",
                  //                             textAlign: TextAlign.left,
                  //                             style:  TextStyle(
                  //                              color: Theme.of(context).accentColor,
                  //                               // fontFamily: "Poppins",
                  //                               fontWeight: FontWeight.w400,
                  //                               fontSize: 15,
                  //                             ),
                  //                           ),
                  //                            ),
                  //                         ),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                ],
              ),
            );
          }),
    );
  }
}
