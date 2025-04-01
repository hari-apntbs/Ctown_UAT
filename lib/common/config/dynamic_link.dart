// TODO: 5-Update Dynamic Link Setting

const firebaseDynamicLinkConfig = {
  "isEnabled": true,
  // Domain is the domain name for your product.
  // Let’s assume here that your product domain is “example.com”.
  // Then you have to mention the domain name as : https://example.page.link.
  // "uriPrefix": "https://up.ctown.jo",
  "uriPrefix": "https://ctown.page.link",
  //The link your app will open
  "link": "https://up.ctown.jo/",
  //----------* Android Setting *----------//
  "androidPackageName": "jo.ctown.ecom",
  "androidAppMinimumVersion": 1,
  //----------* iOS Setting *----------//
  "iOSBundleId": "jo.ctown.ecom",
  "iOSAppMinimumVersion": "1.0.1",
  "iOSAppStoreId": "1469772800"
};
