import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants/general.dart';

class HistoryView extends StatefulWidget {
  @override
  _HistoryViewState createState() => _HistoryViewState();
}
class _HistoryViewState extends State<HistoryView> {
  List<String> history = [];
  @override
  void initState() {
    getKeywords();
    super.initState();
  }

  void getKeywords() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? list = prefs.getStringList(kLocalKey["recentSearches"]!);
      if (list != null && list.isNotEmpty) {
        list.toSet();
        history.addAll(list);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: history.length,
        itemBuilder: (context, index) {
      return Row(children: [
        const Icon(Icons.refresh),
        const SizedBox(
          width: 10,
        ),
        Text(history[index], style: const TextStyle(fontSize: 16)),
        const Spacer(),
        IconButton(
            onPressed: (){
              history.remove(history[index]);
              setState(() {

              });
            },
            icon: const Icon(Icons.close)),
      ]);
    });
  }
}