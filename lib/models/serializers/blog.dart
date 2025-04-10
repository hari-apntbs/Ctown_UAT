import 'package:json_annotation/json_annotation.dart';

import 'images.dart';
import 'user.dart';

part 'blog.g.dart';

@JsonSerializable()
class SerializerBlog {
  int? id;
  String? title;
  String? content;
  String? subTitle;
  @JsonKey(name: 'created_at', nullable: false)
  String? date;
  @JsonKey(name: 'users_permissions_user', nullable: false)
  User? user;
  @JsonKey(name: 'image_feature', nullable: false)
  List<Image>? images;

  SerializerBlog(
      {this.id,
      this.title,
      this.content,
//        this.date,
      this.subTitle,
      this.user,
      this.images});
  factory SerializerBlog.fromJson(Map<String, dynamic> json) =>
      _$SerializerBlogFromJson(json);

  Map<String, dynamic> toJson() => _$SerializerBlogToJson(this);
}
