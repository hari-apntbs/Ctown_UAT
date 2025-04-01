/**
 * Everything Config about the Product Setting
 */

// TODO: 2-Update Product Variant Design Layouts
/// The product variant config
/// Format: "<attribute-slug>": "<layout type>"
/// Layout type can be: "color", "box", "option" or "image".
const ProductVariantLayout = {
  "color": "color",
  "size": "box",
  "product_weight": "option",
  "height": "option",
  "color-image": "image",
};

// TODO: 2-Update Product Detail Layouts
/// use to config the product image height for the product detail
/// height=(percent * width-screen)
const kProductDetail = {
  "height": 0.38,
  "marginTop": 0,
  "safeArea": true,
  "showVideo": true,
  "showThumbnailAtLeast": 1,
  "layout": "simpleType",
  "enableReview": true,
  "attributeImagesSize": 30.0,
};

const kCartDetail = {
  "minAllowTotalCartValue": 0,
  "maxAllowQuantity": 10,
};

// TODO: 2-Update Product Variant Multi-Languages
const kProductVariantLanguage = {
  "en": {
    "color": "Color",
    "size": "Size",
    "product_weight": "Product Weight",
    "height": "Height",
    "color-image": "Color",
  },
  "ar": {
    "color": "اللون",
    "size": "بحجم",
    "height": "ارتفاع",
    "color-image": "اللون",
    "product_weight": "",
  },
  "vi": {
    "color": "Màu",
    "size": "Kích thước",
    "height": "Chiều Cao",
    "color-image": "Màu",
    "product_weight": "trọng lượng sản phẩm",
  },
};

// TODO: 2-Exclude The Category
/// Exclude this categories from the list
const kExcludedCategory = 311;

const kSaleOffProduct = {
  /// Show Count Down for product type SaleOff
  "ShowCountDown": true,
  "Color": '#C7222B',
};
