import 'dart:convert';

ApiResponse apiResponseFromJson(String str) => ApiResponse.fromJson(json.decode(str));

String apiResponseToJson(ApiResponse data) => json.encode(data.toJson());

class ApiResponse {
  bool? status;
  String? errorMessage;
  String? data;

  ApiResponse({
    this.status,
    this.errorMessage,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) => ApiResponse(
        status: json["status"],
        data: json["data"],
        errorMessage: json["error_message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data,
        "error_message": errorMessage,
      };
}
