import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class PostRepository {
  final String _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      print('✔️ Posts cargados exitosamente');
      print('Respuesta cruda: ${response.body.substring(0, 200)}...');

      List jsonList = json.decode(response.body);
      List<Post> posts = jsonList.map((e) => Post.fromJson(e)).toList();
      print('Cantidad de posts: ${posts.length}');

      return posts;
    } else {
      print('❌ Error al cargar los posts. Código: ${response.statusCode}');
      throw Exception('Error al cargar los posts');
    }
  }
}
