import '../../generated/l10n.dart';

class ImageCountry {
  static const String GB = 'assets/images/country/gb.png';
  static const String VN = 'assets/images/country/vn.png';
  static const String JA = 'assets/images/country/ja.png';
  static const String ZH = 'assets/images/country/zh.png';
  static const String ES = 'assets/images/country/es.png';
  static const String AR = 'assets/images/country/ar.png';
  static const String RO = 'assets/images/country/ro.png';
  static const String TR = 'assets/images/country/tr.png';
  static const String IT = 'assets/images/country/it.png';
  static const String ID = 'assets/images/country/id.png';
  static const String DE = 'assets/images/country/de.png';
  static const String BR = 'assets/images/country/br.png';
  static const String FR = 'assets/images/country/fr.png';
  static const String HU = 'assets/images/country/hu.png';
  static const String RU = 'assets/images/country/ru.png';
  static const String HE = 'assets/images/country/he.png';
  static const String TH = 'assets/images/country/th.png';
}

List<Map<String, dynamic>> getLanguages([context]) {
  return [
    {
      "name": context != null ? S.of(context).english : "English",
      "icon": ImageCountry.GB,
      "code": "en",
      "text": "English",
      "storeViewCode": "en"
    },
    {
      "name": context != null ? S.of(context).arabic : "عربى",
      "icon": ImageCountry.AR,
      "code": "ar",
      "text": "عربى",
      "storeViewCode": "ar"
    },
    // {
    //   "name": context != null ? S.of(context).vietnamese : "Vietnam",
    //   "icon": ImageCountry.VN,
    //   "code": "vi",
    //   "text": "Vietnam",
    //   "storeViewCode": ""
    // },
    // {
    //   "name": context != null ? S.of(context).japanese : "Japanese",
    //   "icon": ImageCountry.JA,
    //   "code": "ja",
    //   "text": "Japanese",
    //   "storeViewCode": ""
    // },
    // {
    //   "name": context != null ? S.of(context).chinese : "Chinese",
    //   "icon": ImageCountry.ZH,
    //   "code": "zh",
    //   "text": "Chinese",
    //   "storeViewCode": ""
    // },
    // {
    //   "name": context != null ? S.of(context).indonesian : "Indonesian",
    //   "icon": ImageCountry.ID,
    //   "code": "id",
    //   "text": "Indonesian",
    //   "storeViewCode": "id"
    // },
    // {
    //   "name": context != null ? S.of(context).spanish : "Spanish",
    //   "icon": ImageCountry.ES,
    //   "code": "es",
    //   "text": "Spanish",
    //   "storeViewCode": ""
    // },

    // {
    //   "name": context != null ? S.of(context).romanian : "Romanian",
    //   "icon": ImageCountry.RO,
    //   "code": "ro",
    //   "text": "Romanian",
    //   "storeViewCode": "ro"
    // },
    // {
    //   "name": context != null ? S.of(context).turkish : "Turkish",
    //   "icon": ImageCountry.TR,
    //   "code": "tr",
    //   "text": "Turkish",
    //   "storeViewCode": "tr"
    // },
    // {
    //   "name": context != null ? S.of(context).italian : "Italian",
    //   "icon": ImageCountry.IT,
    //   "code": "it",
    //   "text": "Italian",
    //   "storeViewCode": "it"
    // },
    // {
    //   "name": context != null ? S.of(context).german : "German",
    //   "icon": ImageCountry.DE,
    //   "code": "de",
    //   "text": "German",
    //   "storeViewCode": "de"
    // },
    // {
    //   "name": context != null ? S.of(context).brazil : "Brazil",
    //   "icon": ImageCountry.BR,
    //   "code": "pt",
    //   "text": "Portuguese",
    //   "storeViewCode": "pt"
    // },
    // {
    //   "name": context != null ? S.of(context).french : "French",
    //   "icon": ImageCountry.FR,
    //   "code": "fr",
    //   "text": "French",
    //   "storeViewCode": "fr"
    // },
    // {
    //   "name": context != null ? S.of(context).hungary : "Hungarian",
    //   "icon": ImageCountry.HU,
    //   "code": "hu",
    //   "text": "Hungarian",
    //   "storeViewCode": "hu"
    // },
    // {
    //   "name": context != null ? S.of(context).russian : "Русский",
    //   "icon": ImageCountry.RU,
    //   "code": "ru",
    //   "text": "Русский",
    //   "storeViewCode": "ru"
    // },
    // {
    //   "name": context != null ? S.of(context).hebrew : "Hebrew",
    //   "icon": ImageCountry.HE,
    //   "code": "he",
    //   "text": "Hebrew",
    //   "storeViewCode": "he"
    // },
    // {
    //   "name": context != null ? S.of(context).thailand : "Thai",
    //   "icon": ImageCountry.TH,
    //   "code": "th",
    //   "text": "Thai",
    //   "storeViewCode": "th"
    // },
  ];
}
