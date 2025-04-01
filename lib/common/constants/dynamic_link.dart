

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_model.dart';
import '../../models/entities/product.dart';
import '../../services/index.dart';
import '../config/dynamic_link.dart';
import '../constants.dart';

class DynamicLinkService {
  Future<String> createDynamicLink(String? storeCode, Product? product) async {
    try{
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: firebaseDynamicLinkConfig['uriPrefix'] as String,
        link: Uri.parse(
            "${firebaseDynamicLinkConfig['link']}$storeCode/catalog/product/view/id/${product?.id}/s/${product?.sku}"),
        androidParameters: AndroidParameters(
          packageName: firebaseDynamicLinkConfig['androidPackageName'] as String,
          minimumVersion: firebaseDynamicLinkConfig['androidAppMinimumVersion'] as int?,
        ),
        iosParameters: IOSParameters(
          bundleId: firebaseDynamicLinkConfig['iOSBundleId'] as String,
          minimumVersion: firebaseDynamicLinkConfig['iOSAppMinimumVersion'] as String?,
          appStoreId: firebaseDynamicLinkConfig['iOSAppStoreId'] as String?,
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
            description: "CTown SuperMarkets",
            imageUrl: Uri.parse("${product?.imageFeature}"),
            title: "${product?.description}"),
      );
      // var dynamicUrl = await parameters.buildUrl();
      final ShortDynamicLink dynamicUrl = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
      return dynamicUrl.shortUrl.toString();
    }
    catch(e){
      print(e.toString());
      return "";
    }
    // final dynamicUrl = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    // printLog("vbsftfhfdgfgh");
    // printLog(storeCode);
    // printLog(productId);
    // printLog(dynamicUrl.shortUrl.toString());
    // printLog(dynamicUrl);
    // return dynamicUrl.shortUrl.toString();
  }

  Future<String> createFirebaseDLink(String? storeCode, String? productId) async {
    String url = firebaseDynamicLinkConfig['uriPrefix'] as String;

    FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: url,
      link: Uri.parse('$url/index\.php/$storeCode/catalog/product/view/id/$productId'),
      androidParameters: AndroidParameters(
          packageName: firebaseDynamicLinkConfig['androidPackageName'] as String,
          minimumVersion: firebaseDynamicLinkConfig['androidAppMinimumVersion'] as int?
      ),
      iosParameters: IOSParameters(
        bundleId: firebaseDynamicLinkConfig['iOSBundleId'] as String,
        minimumVersion: firebaseDynamicLinkConfig['iOSAppMinimumVersion'] as String?,
        appStoreId: firebaseDynamicLinkConfig['iOSAppStoreId'] as String?,
      ),
    );
    final ShortDynamicLink dynamicUrl = await dynamicLinks.buildShortLink(parameters);
    return dynamicUrl.shortUrl.toString();
  }

  Future<void> retrieveDynamicLink(BuildContext context) async {
    final PendingDynamicLinkData? data =
    await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      handleDynamicLink(deepLink, context);
    }
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri? deepLink = dynamicLinkData.link;

      if (deepLink != null) {
        handleDynamicLink(deepLink, context);
      }
    }).onError((handleError) {
      print(handleError.message);
    });
  }

  handleDynamicLink(Uri url, BuildContext context) async {
    try{
      final _service = Services();
      Uri uri = Uri.parse(url.path);
      final decoded = Uri.decodeFull(uri.path);
      print(decoded);
      int index = decoded.lastIndexOf("/");
      String name = decoded.substring(index+1, decoded.length);
      printLog("========name");
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: kLoadingWidget,
      );
      var productData = await _service.searchProducts(
          name: name,
          categoryId: null,
          tag: "",
          attribute: "",
          attributeId: "",
          page: 1,
          lang: Provider.of<AppModel>(context, listen: false).langCode,
          isBarcode: false);
      Navigator.of(context, rootNavigator: true).pop();
      if(productData.length > 0){
        Navigator.of(context).pushNamed(
          RouteList.productDetail,
          arguments: productData[0],
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong")));
      }
    }
    catch(e){
      Navigator.of(context, rootNavigator: true).pop();
      printLog(e.toString());
    }
  }

//   final DynamicLinkParameters parameters = DynamicLinkParameters(
//       uriPrefix: firebaseDynamicLinkConfig['uriPrefix'],
//       link: Uri.parse("${firebaseDynamicLinkConfig['link']}"),
//       androidParameters: AndroidParameters(
//         packageName: firebaseDynamicLinkConfig['androidPackageName'],
//         minimumVersion: firebaseDynamicLinkConfig['androidAppMinimumVersion'],
//       ),
//       iosParameters: IosParameters(
//         bundleId: firebaseDynamicLinkConfig['iOSBundleId'],
//         minimumVersion: firebaseDynamicLinkConfig['iOSAppMinimumVersion'],
//         appStoreId: firebaseDynamicLinkConfig['iOSAppStoreId'],
//       ));
//
//   void generateFirebaseDynamicLink(BuildContext context) async {
//     printLog("vbcvbdfgsdfads");
//     final Uri dynamicUrl = await parameters.buildUrl();
//     printLog("vbsftfhfdgfgh");
//     printLog(dynamicUrl);
//     // final Product product = await MagentoApi().dynamiclink();
//     printLog(
//         '[dynamic_link] Your Autogenerated Firebase Dynamic Link: $dynamicUrl');
//     // printLog(
//     //     '[dynamic_link] Your Autogenerated Firebase Dynamic Link: ${dynamicUrl.path}');
//     //     print("**************");
//     //     print(product.name);
//     //      await Navigator.of(
//     //   context,rootNavigator: true
//     //   //rootNavigator: !isBigScreen(context), // Push in tab for tablet (IPad)
//     // ).pushNamed(
//     //   RouteList.productDetail,
//     //   arguments: product
//     // );
//     // print("Navigation finished");
//     //     if (dynamicUrl != null) {
//     // // Navigator.pushNamed(
//     // //     context, dynamicUrl.path);
//     // return dynamicUrl.toString();
// //      var data = await FirebaseDynamicLinks.instance.getInitialLink();
//
// //     FirebaseDynamicLinks.instance.onLink(onSuccess: (dynamicLink)  async {
// //       print("Main = ${dynamicLink}");
// //       var deepLink = dynamicLink?.link;
//
// //       final queryParams = deepLink.queryParameters;
//
// //       debugPrint('DynamicLinks onLink $deepLink');
// //       print("queryParams $queryParams");
//
// //       if(DynamicLinksConst.inviteUser == deepLink.path){
// //         print("Step 1.......Code Works");
//
// //         /* THIS PART CODE IS NOT WORKING  */
// //         Navigator.of(
// //       context,rootNavigator: true
// //       //rootNavigator: !isBigScreen(context), // Push in tab for tablet (IPad)
// //     ).pushNamed(
// //       RouteList.productDetail,
// //       arguments: product
// //     );
// //         // Login.setActiveContext(context);
// //         // Navigator.push(context,
// //         //   EaseInOutSinePageRoute(
// //         //       widget: SignupPage()), //MaterialPageRoute
// //         // );
// //       }
// //     }, onError: (e) async {
// //       debugPrint('DynamicLinks onError $e');
// //     });
//   }
}

// import 'package:emirates_coop/common/constants/route_list.dart';
// import 'package:emirates_coop/models/index.dart';
// import 'package:emirates_coop/screens/orders/suggested_product_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

// import 'package:flutter/material.dart';

// FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

// class FirebaseDynamicLinkService{

//   static Future<String> createDynamicLink(bool  short, Product product) async{
//     String _linkMessage;

//     final DynamicLinkParameters parameters = DynamicLinkParameters(
//       uriPrefix: 'https://emcoop.ae',
//       link: Uri.parse('https://emcoop.ae/product?id=${product.id}'),
//       androidParameters: AndroidParameters(
//         packageName: 'com.app1001.emiratescoop2',
//         minimumVersion: 125,
//       ),
//     );

//     Uri url;
//     if (short) {
//       final ShortDynamicLink shortLink = await parameters.buildShortLink();
//       url = shortLink.shortUrl;
//     } else {
//       url = await parameters.buildUrl();
//     }

//     _linkMessage = url.toString();
//     return _linkMessage;
//   }

//   static Future<void> initDynamicLink(BuildContext context)async {
//     FirebaseDynamicLinks.instance.onLink(
//       onSuccess: (PendingDynamicLinkData dynamicLink) async{
//         final Uri deepLink = dynamicLink.link;

//         var isStory = deepLink.pathSegments.contains('product');
//         // TODO :Modify Accordingly
//         if(isStory){
//           String id = deepLink.queryParameters['id'];
//           // TODO :Modify Accordingly

//           if(deepLink!=null){

//             // TODO : Navigate to your pages accordingly here

//             try{
//               await firebaseFirestore.collection('product').doc(id).get()
//                   .then((snapshot) {
//                     Product storyData = Product.fromMagentoJson(
//                       snapshot
//                     )
//                     fromSnapshot(snapshot);

//                     return
//                     Navigator.of(
//       context,
//       //rootNavigator: !isBigScreen(context), // Push in tab for tablet (IPad)
//     ).pushNamed(
//       RouteList.productDetail,
//       arguments: storyData
//     );
//                     // Navigator.push(context, MaterialPageRoute(builder: (context) =>
//                     //   Product
//                     // ));
//               });
//             }catch(e){
//               print(e);
//             }
//           }else{
//             return null;
//           }
//         }
//       }, onError: (OnLinkErrorException e) async{
//         print('link error');
//       }
//     );

//     final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
//     try{
//       final Uri deepLink = data.link;
//       var isStory = deepLink.pathSegments.contains('storyData');
//       if(isStory){ // TODO :Modify Accordingly
//         String id = deepLink.queryParameters['id']; // TODO :Modify Accordingly

//         // TODO : Navigate to your pages accordingly here

//         // try{
//         //   await firebaseFirestore.collection('Stories').doc(id).get()
//         //       .then((snapshot) {
//         //     StoryData storyData = StoryData.fromSnapshot(snapshot);
//         //
//         //     return Navigator.push(context, MaterialPageRoute(builder: (context) =>
//         //         StoryPage(story: storyData,)
//         //     ));
//         //   });
//         // }catch(e){
//         //   print(e);
//         // }
//       }
//     }catch(e){
//       print('No deepLink found');
//     }
//   }
// }
