import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class PostRepository {
  final String _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      List jsonList = json.decode(response.body);
      return jsonList.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar los posts');
    }
  }
}
