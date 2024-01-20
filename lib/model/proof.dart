import 'package:json_annotation/json_annotation.dart';
import 'package:openprices/model/proof_type.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import '../model/json_object.dart';

part 'proof.g.dart';

@JsonSerializable()
class Proof extends JsonObject {
  @JsonKey()
  int? id;

  @JsonKey(name: 'file_path')
  String? filePath;

  @JsonKey()
  String? mimetype;

  @JsonKey()
  ProofType? type;

  @JsonKey()
  String? owner;

  @JsonKey(fromJson: JsonHelper.stringTimestampToDate)
  DateTime? created;

  @JsonKey(name: 'is_public')
  bool? isPublic;

  Proof();

  factory Proof.fromJson(Map<String, dynamic> json) => _$ProofFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProofToJson(this);
}
