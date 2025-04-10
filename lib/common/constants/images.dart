/// config splash screen
// const kSplashScreen =
//     "assets/images/splashscreen.flr";
const kSplashScreen = "assets/images/splashscreen.png";
//const kSplashScreen = "assets/images/splashscreen.png";

/// Splash screen type. Can be either "flare", "animated", "zoomIn", "static".
/// Reference: https://docs.instasoft.com/store/customization/#2-logo-splash-screen
const kSplashScreenType = "static";

const kProductListLayout = [
  {"layout": "list", "image": "assets/icons/tabs/icon-list.png"},
  // {"layout": "columns", "image": "assets/icons/tabs/icon-columns.png"},
  {"layout": "card", "image": "assets/icons/tabs/icon-card.png"},
  // {"layout": "horizontal", "image": "assets/icons/tabs/icon-horizon.png"},
  {"layout": "listTile", "image": "assets/icons/tabs/icon-lists.png"},
];

const kDefaultImage =
    "https://trello-attachments.s3.amazonaws.com/5d64f19a7cd71013a9a418cf/640x480/1dfc14f78ab0dbb3de0e62ae7ebded0c/placeholder.jpg";

const kLogoImage = 'assets/images/logo.png';

const kProfileBackground =
    "https://images.unsplash.com/photo-1494253109108-2e30c049369b?ixlib=rb-1.2.1&auto=format&fit=crop&w=3150&q=80";

const String kLogo = 'assets/images/logo.png';

const String kEmptySearch = 'assets/images/empty_search.png';

const String kOrderCompleted = 'assets/images/intro-5.png';

/// This is for grid category layout & side menu with sub category layout.
/// id_category : image_category
/// image_category can be network image (begins with "https://")
/// or asset image (begins with "assets/")
const kGridIconsCategories = {
  24: "https://store.io/wp-content/uploads/2015/08/image3xxl-53-150x150.jpg",
  30: "https://store.io/wp-content/uploads/2015/08/image1xxl-45-150x150.jpg",
  19: "https://store.io/wp-content/uploads/2015/08/image1xxl-103-150x150.jpg",
  21: "https://store.io/wp-content/uploads/2015/08/image1xxl-85-150x150.jpg",
  25: "https://store.io/wp-content/uploads/2015/07/image1xxl-11-150x150.jpg",
  27: "https://store.io/wp-content/uploads/2015/07/image2xxl-51-150x150.jpg",
  29: "https://store.io/wp-content/uploads/2015/07/image2xxl-5-150x150.jpg"
};

/// Image proxy URL when build on Web
// const kImageProxy = '';
const kImageProxy = 'https://cors-anywhere.herokuapp.com/';
