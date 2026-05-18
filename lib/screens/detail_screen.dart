import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../models/video_model.dart';

class DetailScreen extends StatefulWidget {
  final int videoId;
  const DetailScreen({super.key, required this.videoId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _supabaseService = SupabaseService();
  VideoModel? _video;
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    final video = await _supabaseService.getVideoById(widget.videoId);
    if (video != null) {
      _video = video;
      _isFavorite = await _supabaseService.isFavorite(video.id);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleFavorite() async {
    if (_video == null) return;
    
    if (_isFavorite) {
      await _supabaseService.removeFavorite(_video!.id);
      setState(() => _isFavorite = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Removido dos favoritos')),
      );
    } else {
      await _supabaseService.addFavorite(_video!.id);
      setState(() => _isFavorite = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicionado aos favoritos!')),
      );
    }
  }

  Future<void> _watchVideo() async {
    await _supabaseService.addToHistory(_video!.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Adicionado ao histórico!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_video == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vídeo não encontrado')),
        body: const Center(child: Text('Vídeo não encontrado')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.pink[200],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _video!.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 5)],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.pink[400]!,
                      Colors.pink[200]!,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_circle_filled,
                    size: 100,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                  size: 28,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.pink[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _video!.category,
                          style: TextStyle(color: Colors.pink[700]),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.star, color: Colors.yellow[700], size: 20),
                      const SizedBox(width: 4),
                      Text('4.5', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Sinopse',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _video!.description,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _watchVideo,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('ASSISTIR AGORA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[400],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}