import 'dart:convert';

// ignore: prefer_relative_imports
import 'package:ctown/frameworks/magento/services/magento.dart';
import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';

enum StatusOrder {
  pendding,
  onHold,
  failed,
  cancelled,
  processing,
  completed,
  refunded
}

class OrderHistory {
  String? orderId;
  String? comment;
  String? status;
  String? createdAt;
  OrderHistory({
    this.orderId,
    this.comment,
    this.status,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'comment': comment,
      'status': status,
      'created_at': createdAt,
    };
  }

  factory OrderHistory.fromMap(Map<String, dynamic>? map) {
    var orders = OrderHistory();
    if(map != null ){
      orders.orderId = map['order_id'] ?? "";
      orders.comment = map['comment'] ?? "";
      orders.status = map['status'] ?? "";
      orders.createdAt = map['created_at'] ?? "";
    }
    return orders;
  }

  String toJson() => json.encode(toMap());

  factory OrderHistory.fromJson(String source) =>
      OrderHistory.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderHistory(orderId: $orderId, comment: $comment, status: $status, created_at: $createdAt)';
  }
}

class TimelineTracking extends StatefulWidget {
  final Axis axisTimeLine;
  final String? orderId;
  // final String status;
  // final DateTime createdAt;
  // final DateTime dateModified;
  // final String description;

  TimelineTracking({Key? key, this.axisTimeLine = Axis.vertical, this.orderId})
      : super(key: key);
  @override
  _TimelineTrackingState createState() => _TimelineTrackingState();
}

class _TimelineTrackingState extends State<TimelineTracking> {
  var statusOrderSuccessNotFail = [
    StatusOrder.pendding,
    StatusOrder.onHold,
    StatusOrder.processing,
    StatusOrder.completed
  ];

  var statusOrderSuccessIsFail = [
    StatusOrder.pendding,
    StatusOrder.failed,
    StatusOrder.processing,
    StatusOrder.completed
  ];

  var statusOrderSuccessRefunded = [
    StatusOrder.pendding,
    StatusOrder.onHold,
    StatusOrder.processing,
    StatusOrder.completed,
    StatusOrder.refunded
  ];

  var statusOrderCancel = [
    StatusOrder.pendding,
    StatusOrder.failed,
    StatusOrder.cancelled
  ];

  get isAxisVertical => widget.axisTimeLine == Axis.vertical;
  List<OrderHistory>? orderHistory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getOrderStatus();
  }

  _getOrderStatus() {
    MagentoApi().getOrderHistory(widget.orderId).then(
      (value) {
        setState(() {
          orderHistory = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget renderMain;
    if (orderHistory == null) {
      //show loading widget
      return Container(height: 80, child: kLoadingWidget(context));
    }
    if (orderHistory!.isEmpty) {
      return Center(
        child: Container(
          child: const Text('No data to show'),
        ),
      );
    }
    if (isAxisVertical) {
      renderMain = Column(children: _renderStatus(orderHistory!));
    } else {
      renderMain = Row(children: _renderStatus(orderHistory!));
    }
    return Center(
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: SingleChildScrollView(
            child: renderMain,
            scrollDirection: isAxisVertical ? Axis.vertical : Axis.horizontal,
          )),
    );
  }

  String converTime(DateTime datetime) {
    String month =
        datetime.month < 10 ? "0${datetime.month}" : "${datetime.month}";
    return "${datetime.day}.$month.${datetime.year}";
  }

  Widget _renderItem(
      {required int index,
      required String time,
      required String title,
      required String description,
      String? status,
      String? statusCurrent,
      required bool isActive,
      bool showLine = true}) {
    Widget date = SizedBox(
      width: isAxisVertical ? MediaQuery.of(context).size.width * 0.2 : null,
      height: 50.0,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          time, //!= null ? converTime(time) : "",
          textAlign: TextAlign.end,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );

    List<Widget> contentInLine = [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Center(
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
                color:
                    isActive ? Theme.of(context).primaryColor : Colors.black54,
                borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      showLine
          ? _buildLine(true, isActive && status != statusCurrent)
          : const SizedBox()
    ];

    Widget content = SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        height: description.isEmpty ? 25.0 : null,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(fontSize: 12),
              ),
              description.isEmpty
                  ? Container(
                      width: 0.0,
                      height: 0.0,
                    )
                  : Text(
                      description,
                      style: const TextStyle(fontSize: 10),
                    )
            ],
          ),
        ));

    if (isAxisVertical) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          date,
          Container(
            child: Column(
              children: contentInLine,
            ),
          ),
          const SizedBox(width: 4),
          content
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 120,
            child: content,
          ),
          Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Row(children: contentInLine)),
          date
        ],
      );
    }
  }

  Widget _buildLine(bool visible, bool isActive) {
    return Container(
      width: isAxisVertical ? (visible ? 2.0 : 0.0) : double.infinity,
      height: isAxisVertical ? 30 : (visible ? 2.0 : 0.0),
      color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade400,
    );
  }

  List<Widget> _renderStatus(List<OrderHistory> orderHistory) {
    List<Widget> listStatus = [];
    String statusOrder = orderHistory.last.status ?? '';
    //List<StatusOrder> flowHandleStatus = statusOrderSuccessNotFail;

    // switch (_status) {
    //   case "on-hold": //Thể hiện timeline : Pendding(active) -> On-Hold(active) -> Processing -> Completed
    //     statusOrder = StatusOrder.onHold;
    //     flowHandleStatus = statusOrderSuccessNotFail;
    //     break;
    //   case "pendding": //Thể hiện timeline : Pendding(active) -> On-Hold -> Processing -> Completed
    //     statusOrder = StatusOrder.pendding;
    //     flowHandleStatus = statusOrderSuccessNotFail;
    //     break;
    //   case "processing": //Thể hiện timeline : Pendding(active) -> On-Hold(active) -> Processing(active) -> Completed
    //     statusOrder = StatusOrder.processing;
    //     flowHandleStatus = statusOrderSuccessNotFail;
    //     break;
    //   case "cancelled": //Thể hiện timeline : Pendding(active) -> Failed(active) -> Cancelled(active)
    //     statusOrder = StatusOrder.cancelled;
    //     flowHandleStatus = statusOrderCancel;
    //     break;
    //   case "refunded": //Thể hiện timeline : Pendding(active) -> On-Hold(active) -> Processing(active) -> Completed(active) -> Refunded(active)
    //     statusOrder = StatusOrder.refunded;
    //     flowHandleStatus = statusOrderSuccessRefunded;
    //     break;

    //   case "completed": //Thể hiện timeline : Pendding(active) -> On-Hold(active) -> Processing(active) -> Completed(active)
    //     statusOrder = StatusOrder.completed;
    //     flowHandleStatus = statusOrderSuccessNotFail;
    //     break;

    //   case "failed": //Thể hiện timeline : Pendding(active) -> Failed(active) -> Processing -> Completed
    //     statusOrder = StatusOrder.failed;
    //     flowHandleStatus = statusOrderSuccessIsFail;
    //     break;
    //   default:
    //     statusOrder = StatusOrder.pendding;
    //     flowHandleStatus = statusOrderSuccessNotFail;
    // }

    for (var i = 0; i < orderHistory.length; i++) {
      listStatus.add(_renderItem(
        index: i,
        statusCurrent: statusOrder,
        isActive: true, //i <= flowHandleStatus.indexOf(statusOrder),
        title: orderHistory[i].status!, // getTitleStatus(flowHandleStatus[i]),
        showLine: i < (orderHistory.length - 1),
        status: orderHistory[i].status,
        // time: DateTime.parse(
        //     orderHistory[i].createdAt), // : (i == flowHandleStatus.indexOf(statusOrder) ? widget.dateModified : null),
        time: orderHistory[i].createdAt!,
        // description: "",
        description: orderHistory[i].comment ?? "",
      ));
    }
    return listStatus;
  }

  Color getColor(StatusOrder status) {
    switch (status) {
      case StatusOrder.onHold:
        return HexColor(kOrderStatusColor["on-hold"]);
      case StatusOrder.pendding:
        return HexColor(kOrderStatusColor["pendding"]);
      case StatusOrder.failed:
        return HexColor(kOrderStatusColor["failed"]);
      case StatusOrder.completed:
        return HexColor(kOrderStatusColor["completed"]);
      case StatusOrder.cancelled:
        return HexColor(kOrderStatusColor["cancelled"]);
      case StatusOrder.refunded:
        return HexColor(kOrderStatusColor["refunded"]);
      case StatusOrder.processing:
        return HexColor(kOrderStatusColor["processing"]);
      default:
        return Colors.white;
    }
  }

  String getTitleStatus(StatusOrder status) {
    switch (status) {
      case StatusOrder.onHold:
        return S.of(context).orderStatusOnHold;
      case StatusOrder.pendding:
        return S.of(context).orderStatusPendingPayment;
      case StatusOrder.failed:
        return S.of(context).orderStatusFailed;
      case StatusOrder.processing:
        return S.of(context).orderStatusProcessing;
      case StatusOrder.completed:
        return S.of(context).orderStatusCompleted;
      case StatusOrder.cancelled:
        return S.of(context).orderStatusCancelled;
      case StatusOrder.refunded:
        return S.of(context).orderStatusRefunded;
      default:
        return "";
    }
  }
}
