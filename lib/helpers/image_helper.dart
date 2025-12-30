class ImageHelper {
  // Ganti IP sesuai IP laptopmu (IP Wifi) agar HP/Emulator bisa akses
  static const String baseUrl = "http://10.0.2.2:8000/storage/";

  static String getUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "https://ui-avatars.com/api/?name=User";
    }
    return baseUrl + path;
  }
}