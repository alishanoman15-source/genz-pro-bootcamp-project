import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.genzpro.pk';

  static Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getProfile(int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_profile.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      return data['user'] ?? data;
    }
    return data;
  }

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_profile.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getCourses(
      {String? type, String? category, String? status}) async {
    String url = '$baseUrl/get_courses.php?';
    if (type != null) url += 'type=$type&';
    if (category != null) url += 'category=$category&';
    if (status != null) url += 'status=$status';
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    if (data is List) return data;
    if (data is Map) return data['courses'] ?? data['data'] ?? [];
    return [];
  }

  static Future<Map<String, dynamic>> getCourseDetails(int courseId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/get_course_details.php?course_id=$courseId'));
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      return data['course'] ?? data['data'] ?? data;
    }
    return data;
  }

  static Future<List<dynamic>> getCategories() async {
    final response =
        await http.get(Uri.parse('$baseUrl/get_categories.php'));
    final data = jsonDecode(response.body);
    if (data is List) return data;
    if (data is Map) return data['categories'] ?? data['data'] ?? [];
    return [];
  }

  static Future<Map<String, dynamic>> enroll(
      int userId, int courseId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/enroll.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'course_id': courseId}),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> myEnrollments(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/my_enrollments.php?user_id=$userId'));
    final data = jsonDecode(response.body);
    if (data is List) return data;
    if (data is Map) return data['enrollments'] ?? data['data'] ?? [];
    return [];
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    final response =
        await http.get(Uri.parse('$baseUrl/dashboard.php'));
    return jsonDecode(response.body);
  }
}
