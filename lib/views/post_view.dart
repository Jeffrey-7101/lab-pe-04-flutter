import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/post_viewmodel.dart';

class PostView extends StatelessWidget {
  const PostView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PostViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
              ? Center(child: Text('Error: ${vm.error}'))
              : ListView.builder(
                  itemCount: vm.posts.length,
                  itemBuilder: (_, index) {
                    final post = vm.posts[index];
                    return ListTile(
                      title: Text(post.title),
                      subtitle: Text(post.body),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => vm.getPosts(),
        child: const Icon(Icons.download),
      ),
    );
  }
}
