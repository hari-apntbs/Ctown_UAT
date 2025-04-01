//  try {
//       var endPoint = "?";
//       if (lang == 'ar') {
//         endPoint +=
//             "searchCriteria[filter_groups][0][filters][0][field]=store_id&searchCriteria[filter_groups][0][filters][0][value]=11&searchCriteria[filter_groups][0][filters][0][condition_type]=eq";
//         if (name != null) {
//           String newSearchString = "";
//           List newName = name.split(",");

//           for (int i = 0; i < newName.length; i++) {
//             newSearchString +=
//                 "searchCriteria[filter_groups][0][filters][$i][field]=name&searchCriteria[filter_groups][0][filters][$i][value]=%25${newName[i]}%&searchCriteria[filter_groups][0][filters][$i][condition_type]=like";
//             if (i != newName.length - 1) {
//               newSearchString += "&";
//             }
//           }
//           print("new string " + newSearchString);
//           endPoint += newSearchString;
// // old query
//           // endPoint +=
//           //     "&searchCriteria[filter_groups][1][filters][0][field]=name&searchCriteria[filter_groups][1][filters][0][value]=$name%&searchCriteria[filter_groups][1][filters][0][condition_type]=like";
//         }
//       } else {
//         if (name != null) {
//           if (isBarcode) {
//             endPoint +=
//                 "searchCriteria[filter_groups][0][filters][1][field]=item_barcode&searchCriteria[filter_groups][0][filters][1][value]=$name&searchCriteria[filter_groups][0][filters][1][condition_type]=eq&&searchCriteria[sortOrders][0][field]=category_id&searchCriteria[sortOrders][0][direction]=ASC";
//           } else {
//             String newSearchString = "";
//             List newName = name.split(",");

//             for (int i = 0; i < newName.length; i++) {
//               newSearchString +=
//                   "searchCriteria[filter_groups][0][filters][$i][field]=name&searchCriteria[filter_groups][0][filters][$i][value]=%25${newName[i]}%&searchCriteria[filter_groups][0][filters][$i][condition_type]=like";
//               if (i != newName.length - 1) {
//                 newSearchString += "&";
//               }
//             }
//             print("new string " + newSearchString);
//             endPoint += newSearchString;
//             // old query
//             // endPoint +=
//             //     "searchCriteria[filter_groups][0][filters][0][field]=name&searchCriteria[filter_groups][0][filters][0][value]=$name%&searchCriteria[filter_groups][0][filters][0][condition_type]=like";
//           }
//         }
//         endPoint +=
//             "&searchCriteria[filter_groups][2][filters][0][field]=store_id&searchCriteria[filter_groups][2][filters][0][value]=1&searchCriteria[filter_groups][2][filters][0][condition_type]=eq&&searchCriteria[sortOrders][0][field]=category_id&searchCriteria[sortOrders][0][direction]=ASC";
//       }
//       if (page != null) {
//         endPoint += "&searchCriteria[currentPage]=$page";
//       }
//       if (categoryId != null) {
//         if (lang == 'ar') {
//           endPoint +=
//               "&searchCriteria[filter_groups][3][filters][0][field]=category_id&searchCriteria[filter_groups][3][filters][0][value]=$categoryId&searchCriteria[filter_groups][3][filters][0][condition_type]=eq";
//         } else {
//           endPoint +=
//               "&searchCriteria[filter_groups][1][filters][0][field]=category_id&searchCriteria[filter_groups][1][filters][0][value]=$categoryId&searchCriteria[filter_groups][1][filters][0][condition_type]=eq";
//         }
//       }

//       endPoint += "&searchCriteria[pageSize]=$ApiPageSize";
//       endPoint +=
//           "&searchCriteria[filter_groups][2][filters][0][field]=visibility&searchCriteria[filter_groups][2][filters][0][value]=4";
//       print(
//         MagentoHelper.buildUrl(domain, "ist/products$endPoint"),
//       );
//       var response = await http.get(
//           MagentoHelper.buildUrl(domain, "ist/products$endPoint"),
//           headers: {'Authorization': 'Bearer ' + accessToken});
//       List<Product> list = [];
//       if (response.statusCode == 200) {
//         print("Search query generated");
//         print(
//           MagentoHelper.buildUrl(domain, "ist/products$endPoint"),
//         );
//         print(accessToken);
//         final body = convert.jsonDecode(response.body);
//         print(body);
//         print("response body");
//         // print(body["items"]);
//         if (!MagentoHelper.isEndLoadMore(body)) {
//           for (var item in body["items"]) {
//             Product product = parseProductFromJson(item);
//             // print(product.name + "   " + product.categoryId);
//             list.add(product);
//           }
//         }
//       }

//       /*     // Comparator<Product> nameComparator = (b, a) => b.name.compareTo(a.name);

//       // list.sort(nameComparator);

//       List namesList = name.split(",");
//       List newList = list;
//       List generalList;
//       // for (int i = 0; i < namesList.length; i++) {
//       List l = list.where((element) => element.name.contains("Tiger")).toList();
//       // print(namesList[i]);
//       print("lengtg");
//       print(l.length);
//       l.forEach((element) {
//         print(element);
//       });

//       // }
//       // print("new list");
//       // print(newList.length);
//       int i = 0;
//       newList.sort((a, b) {
//         // Sort results by matching name with keyword position in name

//         if (a.name.toLowerCase().indexOf(namesList[i].toLowerCase()) >
//             b.name.toLowerCase().indexOf(namesList[i].toLowerCase())) {
//           return 1;
//         } else if (a.name.toLowerCase().indexOf(namesList[i].toLowerCase()) <
//             b.name.toLowerCase().indexOf(namesList[i].toLowerCase())) {
//           return -1;
//         } else {
//           // if (a.name.compareTo(b.name) != null) {
//           if (a.name.length < b.name.length) {
//             return 1;
//           } else {
//             return -1;
//           }
//         }
//       });
//       // generalList.addAll(newList);
//       // }
// */
//       /*  List<Product> newList = list;
//       newList.sort((a, b) {
//         // Sort results by matching name with keyword position in name
//         if (a.name.toLowerCase().indexOf(name.toLowerCase()) >
//             b.name.toLowerCase().indexOf(name.toLowerCase())) {
//           return 1;
//         } else if (a.name.toLowerCase().indexOf(name.toLowerCase()) <
//             b.name.toLowerCase().indexOf(name.toLowerCase())) {
//           return -1;
//         } else {
//           if (a.name.length > b.name.length) {
//             return 1;
//           } else {
//             return -1;
//           }
//         }
//       });
// */
//       /**
//        List<Product> newList = list;
//       newList.sort((a, b) {
//         // Sort results by matching name with keyword position in name
//         if (a.name.toLowerCase().indexOf(name.toLowerCase()) >
//             b.name.toLowerCase().indexOf(name.toLowerCase())) {
//           return 1;
//         } else if (a.name.toLowerCase().indexOf(name.toLowerCase()) <
//             b.name.toLowerCase().indexOf(name.toLowerCase())) {
//           return -1;
//         } else {
//           if (a.name.compareTo(b.name) != null) {
//             return 1;
//           } else {
//             return -1;
//           }
//         }
//       });
//        */
//       // print("comparator");

//       // newList.forEach((element) {
//       //   print(element.categoryId);
//       // });
//       // for (int i = 0; i < list.length; i++) {
//       //   if (list[i].name.startsWith(name)) {
//       //     print(name);
//       //   } else {
//       //     print(list[i].name);
//       //     print(false);
//       //   }
//       // }

//       return list;
//       // return newList;
//     }
