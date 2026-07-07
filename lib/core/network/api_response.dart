class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int status;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.status,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? 200,
      data: json.containsKey('data') && json['data'] != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}
