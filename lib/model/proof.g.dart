// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proof.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Proof _$ProofFromJson(Map<String, dynamic> json) => Proof()
  ..id = json['id'] as int?
  ..filePath = json['file_path'] as String?
  ..mimetype = json['mimetype'] as String?
  ..type = $enumDecodeNullable(_$ProofTypeEnumMap, json['type'])
  ..owner = json['owner'] as String?
  ..created = JsonHelper.stringTimestampToDate(json['created'])
  ..isPublic = json['is_public'] as bool?;

Map<String, dynamic> _$ProofToJson(Proof instance) => <String, dynamic>{
      'id': instance.id,
      'file_path': instance.filePath,
      'mimetype': instance.mimetype,
      'type': _$ProofTypeEnumMap[instance.type],
      'owner': instance.owner,
      'created': instance.created?.toIso8601String(),
      'is_public': instance.isPublic,
    };

const _$ProofTypeEnumMap = {
  ProofType.priceTag: 'PRICE_TAG',
  ProofType.receipt: 'RECEIPT',
  ProofType.gdprRequest: 'GDPR_REQUEST',
};
