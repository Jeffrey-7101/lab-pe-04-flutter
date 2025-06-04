import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../repositories/post_repository.dart';

class PostViewModel extends ChangeNotifier {
  final PostRepository _repo = PostRepository();

  List<Post> posts = [];
  bool isLoading = false;
  String? error;

  Future<void> getPosts() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      posts = await _repo.fetchPosts();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
