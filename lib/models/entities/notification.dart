import 'dart:convert' as convert;
import 'package:localstorage/localstorage.dart';

import '../../common/constants.dart';

class storeNotification {
  String? body;
  String? title;
  bool? seen;
  String? date;

  storeNotification.fromJsonFirebase(Map<String, dynamic> json) {
    printLog(" storeNotification.fromJsonFirebase");
    printLog("sdfnnfnrfgnrdgneriger------------------");
    try {
      final data = json['data'];
      final notification =
          data != null && data.keys.isNotEmpty && data["title"] != null
              ? data
              : json['notification'];
      body = notification['body'];
      title = notification['title'];
      seen = false;
      date = DateTime.now().toString();
      printLog(data);
    } catch (e) {
      printLog(e.toString());
    }
  }

  storeNotification.fromOneSignal(osNotification) {
    title = osNotification.payload.title ?? '';
    body = osNotification.payload.body ?? '';
    date = DateTime.now().toString();
    seen = false;
  }

  storeNotification.fromJsonFirebaseLocal(Map<String, dynamic> json) {
    try {
      final data = json['data'];
      final notification =
          data != null && data.keys.isNotEmpty ? data : json['notification'];

      body = notification['body'];
      title = notification['title'];
      seen = false;
      int time = notification['google.sent_time'] ?? ['from'];
      date = DateTime.fromMillisecondsSinceEpoch(time).toString();
    } catch (e) {
      printLog(e.toString());
    }
  }

  storeNotification.fromLocalStorage(Map<String, dynamic> json) {
    try {
      if ((json['body']?.isNotEmpty ?? false) &&
          (json['title']?.isNotEmpty ?? false)) {
        body = json['body'];
        title = json['title'];
        date = json['date'] != null
            ? (DateTime.parse(json['date'])).toString()
            : '';
        seen = false;
      }
    } catch (e) {
      printLog(e.toString());
    }
  }

  storeNotification.from(this.body, this.title) {
    seen = false;
  }

  Map<String, dynamic> toJson() => {
        'body': body,
        'title': title,
        'seen': seen,
        'date': date,
      };

  Future<void> updateSeen(int index) async {
    final LocalStorage storage = LocalStorage("store");
    seen = true;
    try {
      final ready = await storage.ready;
      if (ready) {
        var list = await storage.getItem('notifications');
        list ??= [];
        list[index] = convert.jsonEncode(toJson());
        await storage.setItem('notifications', list);
      }
    } catch (err) {
      printLog(err);
    }
  }

  Future<void> saveToLocal(String? id) async {
    final LocalStorage storage = LocalStorage("store");

    try {
      final ready = await storage.ready;
      if (ready) {
        var list = await storage.getItem('notifications');

        String old = await storage.getItem('message-id').toString();
        if (id != null) {
          if (old.isNotEmpty && id != 'null') {
            if (old == id) return;
            await storage.setItem('message-id', id);
          } else {
            await storage.setItem('message-id', id);
          }
        }
        list ??= [];
        list.insert(0, convert.jsonEncode(toJson()));
        printLog("Note $list");
        await storage.setItem('notifications', list);
      }
    } catch (err) {
      printLog(err);
    }
  }
}
