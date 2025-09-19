class ApiResponse<T> {
  final T data;
  final Map<String, String> headers;

  ApiResponse({required this.data, required this.headers});
}
