class FailedResponse {
  final int status;
  final String message;

  FailedResponse({required this.status, required this.message});

  factory FailedResponse.fromJson(Map<String, dynamic> json) {
    return FailedResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? 'Unknown error',
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };
}
