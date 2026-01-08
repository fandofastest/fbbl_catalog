class ApiConfig {
  static const baseUrl = 'https://fbbl-backend.vercel.app';

  static String url(String path) {
    if (path.startsWith('/')) {
      return '$baseUrl$path';
    }
    return '$baseUrl/$path';
  }
}
