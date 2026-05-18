import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../models/video_model.dart';
import '../widgets/category_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabaseService = SupabaseService();
  List<VideoModel> _allVideos = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final videos = await _supabaseService.getAllVideos();
    final favorites = await _supabaseService.getFavoriteVideoIds();
    
    for (var video in videos) {
      video.isFavorite = favorites.contains(video.id);
    }
    
    setState(() {
      _allVideos = videos;
      _isLoading = false;
    });
  }

  Map<String, List<VideoModel>> get _groupedVideos {
    final Map<String, List<VideoModel>> groups = {};
    for (var video in _allVideos) {
      if (!groups.containsKey(video.category)) {
        groups[video.category] = [];
      }
      groups[video.category]!.add(video);
    }
    return groups;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/favorites');
        break;
      case 2:
        context.go('/history');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink[50]!, Colors.white],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              floating: true,
              pinned: true,
              backgroundColor: Colors.pink[200],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'EduStream',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 5, color: Colors.pink[400]!),
                    ],
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.pink[400]!, Colors.pink[200]!],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      size: 80,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    for (var entry in _groupedVideos.entries)
                      CategorySection(
                        title: entry.key,
                        videos: entry.value,
                        onVideoTap: (video) {
                          context.push('/detail/${video.id}');
                        },
                      ),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pink[600],
        unselectedItemColor: Colors.pink[200],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}