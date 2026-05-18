import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/video_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Auth methods
  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signIn(String email, String password) async {
    // Corrigido: usar signInWithPassword em vez de signIn
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  String? getCurrentUserId() {
    return _supabase.auth.currentSession?.user.id;
  }

  String? getCurrentUserEmail() {
    return _supabase.auth.currentSession?.user.email;
  }

  // Videos methods
  Future<List<VideoModel>> getAllVideos() async {
    final response = await _supabase
        .from('videos')
        .select('*')
        .order('created_at', ascending: false);
    
    return response.map((video) => VideoModel.fromMap(video)).toList();
  }

  Future<VideoModel?> getVideoById(int id) async {
    final response = await _supabase
        .from('videos')
        .select('*')
        .eq('id', id)
        .maybeSingle();
    
    if (response == null) return null;
    return VideoModel.fromMap(response);
  }

  // Favorites methods
  Future<List<int>> getFavoriteVideoIds() async {
    final userId = getCurrentUserId();
    if (userId == null) return [];

    final response = await _supabase
        .from('favorites')
        .select('video_id')
        .eq('user_id', userId);
    
    return response.map<int>((fav) => fav['video_id'] as int).toList();
  }

  Future<List<VideoModel>> getFavoriteVideos() async {
    final userId = getCurrentUserId();
    if (userId == null) return [];

    final response = await _supabase
        .from('favorites')
        .select('videos(*)')
        .eq('user_id', userId);
    
    final List<VideoModel> videos = [];
    for (var item in response) {
      if (item['videos'] != null) {
        videos.add(VideoModel.fromMap(item['videos']));
      }
    }
    return videos;
  }

  Future<void> addFavorite(int videoId) async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    await _supabase.from('favorites').insert({
      'user_id': userId,
      'video_id': videoId,
    });
  }

  Future<void> removeFavorite(int videoId) async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('video_id', videoId);
  }

  Future<bool> isFavorite(int videoId) async {
    final userId = getCurrentUserId();
    if (userId == null) return false;

    final response = await _supabase
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('video_id', videoId);
    
    return response.isNotEmpty;
  }

  // Watch history methods
  Future<void> addToHistory(int videoId) async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    // Check if already exists
    final existing = await _supabase
        .from('watch_history')
        .select()
        .eq('user_id', userId)
        .eq('video_id', videoId);
    
    if (existing.isNotEmpty) {
      // Update timestamp
      await _supabase
          .from('watch_history')
          .update({'watched_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .eq('video_id', videoId);
    } else {
      // Insert new
      await _supabase.from('watch_history').insert({
        'user_id': userId,
        'video_id': videoId,
        'watched_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<List<VideoModel>> getWatchHistory() async {
    final userId = getCurrentUserId();
    if (userId == null) return [];

    final response = await _supabase
        .from('watch_history')
        .select('videos(*)')
        .eq('user_id', userId)
        .order('watched_at', ascending: false);
    
    final List<VideoModel> videos = [];
    for (var item in response) {
      if (item['videos'] != null) {
        videos.add(VideoModel.fromMap(item['videos']));
      }
    }
    return videos;
  }

  Future<void> clearHistory() async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    await _supabase
        .from('watch_history')
        .delete()
        .eq('user_id', userId);
  }

  Future<void> removeFromHistory(int videoId) async {
    final userId = getCurrentUserId();
    if (userId == null) return;

    await _supabase
        .from('watch_history')
        .delete()
        .eq('user_id', userId)
        .eq('video_id', videoId);
  }
}
