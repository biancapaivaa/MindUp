import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/supabase_service.dart';
import '../models/video_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _supabaseService = SupabaseService();
  List<VideoModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await _supabaseService.getWatchHistory();
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Histórico'),
        content: const Text('Tem certeza que deseja limpar todo o histórico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _supabaseService.clearHistory();
      setState(() => _history = []);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Histórico limpo com sucesso')),
      );
    }
  }

  Future<void> _removeFromHistory(VideoModel video) async {
    await _supabaseService.removeFromHistory(video.id);
    setState(() {
      _history.removeWhere((v) => v.id == video.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${video.title} removido do histórico')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico',
        style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pink[200],
        elevation: 0,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearHistory,
            ),
        ],
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
            : _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.pink[200],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum vídeo assistido',
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
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final video = _history[index];
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
                                Icons.play_circle_filled,
                                color: Colors.pink[400],
                                size: 35,
                              ),
                            ),
                          ),
                          title: Text(
                            video.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(video.category),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () => _removeFromHistory(video),
                          ),
                          onTap: () {
                            context.push('/detail/${video.id}').then((_) => _loadHistory());
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}