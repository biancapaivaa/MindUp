import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../models/video_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _supabaseService = SupabaseService();
  List<VideoModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favorites = await _supabaseService.getFavoriteVideos();
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(VideoModel video) async {
    await _supabaseService.removeFavorite(video.id);
    setState(() {
      _favorites.removeWhere((v) => v.id == video.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${video.title} removido dos favoritos')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
        backgroundColor: Colors.pink[200],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[50]!, Colors.white],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 80,
                          color: Colors.pink[200],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum favorito ainda',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.pink[300],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.go('/home'),
                          child: Text(
                            'Explorar vídeos',
                            style: TextStyle(color: Colors.pink[600]),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final video = _favorites[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 60,
                              height: 60,
                              color: Colors.pink[100],
                              child: Icon(
                                Icons.video_library,
                                color: Colors.pink[400],
                                size: 30,
                              ),
                            ),
                          ),
                          title: Text(
                            video.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(video.category),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => _removeFavorite(video),
                          ),
                          onTap: () {
                            context.push('/detail/${video.id}').then((_) => _loadFavorites());
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}