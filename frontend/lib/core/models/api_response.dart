class ApiResponse<T> {
  final String? message;
  final T? data;

  ApiResponse({this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromData,
  ) {
    final rawData = json['data'];
    return ApiResponse<T>(
      message: json['message']?.toString(),
      data: rawData != null ? fromData(rawData) : null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toData) => {
    if (message != null) 'message': message,
    if (data != null) 'data': toData(data as T),
  };
}
