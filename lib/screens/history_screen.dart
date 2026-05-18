import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';
import '../models/video_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final _supabaseService = SupabaseService();
  List<VideoModel> _history = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Paleta rosa elegante
  static const Color _background = Color(0xFFFEF6F8); // Rosa quase branco
  static const Color _surface = Colors.white;
  static const Color _primary = Color(0xFFE91E63); // Rosa vibrante
  static const Color _primaryDark = Color(0xFFC2185B); // Rosa mais intenso
  static const Color _primaryLight = Color(0xFFFCE4EC); // Rosa clarinho
  static const Color _textPrimary = Color(0xFF2D1B2E); // Quase preto com leve tom roxo
  static const Color _textSecondary = Color(0xFF9E6D8C); // Rosa acinzentado
  static const Color _divider = Color(0xFFF0E1E6);
  static const Color _danger = Color(0xFFF44336);

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      builder: (context) => _buildStyledDialog(
        title: 'Limpar histórico',
        content: 'Esta ação removerá todos os vídeos do seu histórico.',
        confirmText: 'Limpar',
        confirmColor: _danger,
      ),
    );

    if (confirm == true) {
      await _supabaseService.clearHistory();
      setState(() => _history = []);
      _showStyledSnackBar('Histórico limpo');
    }
  }

  Future<void> _removeFromHistory(VideoModel video) async {
    await _supabaseService.removeFromHistory(video.id);
    setState(() {
      _history.removeWhere((v) => v.id == video.id);
    });
    _showStyledSnackBar('Vídeo removido');
  }

  void _showStyledSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildStyledDialog({
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: _surface,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              size: 48,
              color: confirmColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: _textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _textSecondary,
                      side: const BorderSide(color: _divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 12,
                    width: 100,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFFFCE4EC),
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110,
            floating: true,
            pinned: true,
            backgroundColor: _surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Histórico',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: _textPrimary,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
            ),
            actions: [
              if (_history.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: TextButton.icon(
                      onPressed: _clearHistory,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Limpar tudo'),
                      style: TextButton.styleFrom(
                        foregroundColor: _danger,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            sliver: _isLoading
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildShimmerItem(),
                      childCount: 5,
                    ),
                  )
                : _history.isEmpty
                    ? SliverFillRemaining(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _primaryLight,
                                ),
                                child: Icon(
                                  Icons.history_rounded,
                                  size: 56,
                                  color: _primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Nenhum vídeo assistido',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Seus vídeos assistidos aparecerão aqui.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _textSecondary,
                                ),
                              ),
                              const SizedBox(height: 32),
                              OutlinedButton.icon(
                                onPressed: () => context.go('/home'),
                                icon: const Icon(Icons.play_arrow, size: 18),
                                label: const Text('Explorar vídeos'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _primary,
                                  side: BorderSide(color: _primary),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final video = _history[index];
                            return FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.05),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: _animationController,
                                  curve: Interval(
                                    index * 0.05,
                                    1.0,
                                    curve: Curves.easeOutCubic,
                                  ),
                                )),
                                child: _buildHistoryCard(video),
                              ),
                            );
                          },
                          childCount: _history.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(VideoModel video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/detail/${video.id}').then((_) => _loadHistory());
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 90,
                        height: 90,
                        color: _primaryLight,
                        child: Icon(
                          Icons.play_circle_filled,
                          size: 42,
                          color: _primary,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _surface.withOpacity(0.9),
                          border: Border.all(color: _divider),
                        ),
                        child: Text(
                          video.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: _textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatWatchTime(video.watchedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: _textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _textSecondary.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.play_circle_outline,
                            size: 14,
                            color: _primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Continuar',
                            style: TextStyle(
                              fontSize: 12,
                              color: _primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _divider.withOpacity(0.5),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: _textSecondary,
                    onPressed: () => _removeFromHistory(video),
                    splashRadius: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatWatchTime(DateTime? watchedAt) {
    if (watchedAt == null) return 'Assistido recentemente';
    final now = DateTime.now();
    final difference = now.difference(watchedAt);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(watchedAt);
    } else if (difference.inDays > 0) {
      return 'Há ${difference.inDays} dia${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Há ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Há ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Agora mesmo';
    }
  }
}