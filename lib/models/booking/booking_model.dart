import '../../services/index.dart';
import '../entities/index.dart';
import 'booking_controller.dart';

class BookingModel {
  final String idProduct;
  final Services _service = Services();
  final BookingController _bookingController = BookingController();
  BookingModel(this.idProduct) {
    _bookingController.isLoadingSlot = true;
    getListStaff().then((value) {
      var idStaff;
      if (_bookingController.staffs.isNotEmpty) {
        idStaff = _bookingController.staffs.first.id;
      }

      updateSlot(DateTime.now(), idStaff)
          .then((value) => _bookingController.isLoadingSlot = false);
    });
  }
  BookingController get controller => _bookingController;

  Future<void> getListStaff() async {
    var listStaff = await _service.getListStaff(idProduct);
    if (listStaff!.isNotEmpty) {
      _bookingController.staffs = listStaff as List<StaffBooking>;
    }
  }

  Future<void> updateSlot(DateTime date, [int? idStaff]) async {
    _bookingController.isLoadingSlot = true;
    String dateChoose = '${date.year}-${date.month}-${date.day}';
    _bookingController.listSlotSelect!.clear();

    final listSlot = await _service.getSlotBooking(
      idProduct,
      '$idStaff',
      dateChoose,
    );

    if (listSlot?.isNotEmpty ?? false) {
      _bookingController.listSlotSelect = listSlot;
    }
    _bookingController.isLoadingSlot = false;
  }
}
