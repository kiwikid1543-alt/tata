// lib/models/dto/center_dto.dart

class CenterDto {
  final String? cntrId;
  final String? cntrNm;
  final String? lat;
  final String? lot;
  final String? cntrRoadNmAddr;
  final String? cntrTelno;
  final String? lclgvNm;

  CenterDto({
    this.cntrId,
    this.cntrNm,
    this.lat,
    this.lot,
    this.cntrRoadNmAddr,
    this.cntrTelno,
    this.lclgvNm,
  });

  factory CenterDto.fromJson(Map<String, dynamic> json) {
    return CenterDto(
      cntrId: json['cntrId']?.toString(),
      cntrNm: json['cntrNm']?.toString(),
      lat: json['lat']?.toString(),
      lot: json['lot']?.toString(),
      cntrRoadNmAddr: json['cntrRoadNmAddr']?.toString(),
      cntrTelno: json['cntrTelno']?.toString(),
      lclgvNm: json['lclgvNm']?.toString(),
    );
  }
}
