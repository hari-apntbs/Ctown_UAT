class Credentials {
  Credentials._internal();

  static const applicationID = "1M2N70JNTT";
  static const searchOnlyKey = "6fb421709d3ae87bb772988c9a1615d9";

  static String getSearchIndex(String store) {
    String searchIndex = "";
    if(store.contains("en")){
      searchIndex = "Ctown SM Tela Al-Ali_En_75";
    }
    else {
      searchIndex = "Ctown SM Tela Al-Ali_ar_76";
    }
    return searchIndex;
  }
}
