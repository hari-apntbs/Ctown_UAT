class States {
  List<Data>? data;

  States({this.data});

  States.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? name; 
  List<Area>? area;

  Data({this.id, this.name, this.area});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['city_id'];
    name = json['city_name'];
    if (json['area'] != null) {
      area = <Area>[];
      json['area'].forEach((v) {
        area!.add(Area.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['city_id'] = id;
    data['city_name'] = name;
    if (area != null) {
      data['area'] = area!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Area {
  String? areaId;
  String? areaName;

  Area({this.areaId, this.areaName});

  Area.fromJson(Map<String, dynamic> json) {
    areaId = json['area_id'];
    areaName = json['area_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['area_id'] = this.areaId;
    data['area_name'] = this.areaName;
    return data;
  }
}
