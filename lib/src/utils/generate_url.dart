Uri generateUrl(String baseUrl, String endpoint) {
  return Uri.https(
    baseUrl,
    endpoint,
  );
}
