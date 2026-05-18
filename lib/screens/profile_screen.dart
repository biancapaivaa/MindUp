import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabaseService = SupabaseService();
  final _supabase = Supabase.instance.client;

  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        await _supabase.from('profiles').insert({
          'id': userId,
          'email': _supabase.auth.currentUser?.email,
          'full_name': 'Usuário',
          'course': 'Não informado',
          'bio': 'Olá! Estou usando o StreamEduc.',
        });
        _userProfile = {
          'full_name': 'Usuário',
          'email': _supabase.auth.currentUser?.email,
          'course': 'Não informado',
          'bio': 'Olá! Estou usando o StreamEduc.',
          'total_hours_watched': 0,
          'courses_completed': 0,
        };
      } else {
        _userProfile = response;
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile(Map<String, dynamic> updates) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('profiles').update(updates).eq('id', userId);
      setState(() {
        _userProfile?.addAll(updates);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _supabaseService.signOut();
      if (mounted) context.go('/login');
    }
  }

  void _editProfileDialog() {
    final nameController = TextEditingController(text: _userProfile?['full_name']);
    final bioController = TextEditingController(text: _userProfile?['bio']);
    final courseController = TextEditingController(text: _userProfile?['course']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: 'Biografia',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: courseController,
                decoration: const InputDecoration(
                  labelText: 'Curso',
                  prefixIcon: Icon(Icons.school),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateProfile({
                'full_name': nameController.text,
                'bio': bioController.text,
                'course': courseController.text,
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[400]),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.pink[200],
        elevation: 0,
        actions: [
          // Botão de editar perfil
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editProfileDialog,
            tooltip: 'Editar perfil',
          ),
          // Botão de sair (logout) ao lado do editar
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair da conta',
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
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text('Erro: $_errorMessage'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUserProfile,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink[400]),
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUserProfile,
                    color: Colors.pink[400],
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          _buildProfileHeader(),
                          const SizedBox(height: 24),
                          _buildStatsCards(),
                          const SizedBox(height: 24),
                          _buildInfoCard(),
                          const SizedBox(height: 24),
                          _buildMenuOptions(),
                          const SizedBox(height: 32),
                          // Botão de logout removido daqui (agora está na AppBar)
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.pink[200],
              backgroundImage: _userProfile?['avatar_url'] != null
                  ? NetworkImage(_userProfile!['avatar_url'])
                  : null,
              child: _userProfile?['avatar_url'] == null
                  ? Icon(Icons.person, size: 70, color: Colors.pink[400])
                  : null,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.pink[400],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Em breve você poderá alterar sua foto!')),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _userProfile?['full_name'] ?? 'Usuário',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          _userProfile?['email'] ?? '',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        if (_userProfile?['bio'] != null && _userProfile!['bio'].toString().isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _userProfile!['bio'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _statCard(
            icon: Icons.play_circle_filled,
            label: 'Horas assistidas',
            value: '${_userProfile?['total_hours_watched'] ?? 0}h',
            color: Colors.pink[400]!,
          ),
          const SizedBox(width: 16),
          _statCard(
            icon: Icons.assignment_turned_in,
            label: 'Cursos concluídos',
            value: '${_userProfile?['courses_completed'] ?? 0}',
            color: Colors.pink[400]!,
          ),
        ],
      ),
    );
  }

  Widget _statCard({required IconData icon, required String label, required String value, required Color color}) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _infoRow(
              icon: Icons.school,
              label: 'Curso',
              value: _userProfile?['course'] ?? 'Não informado',
            ),
            const Divider(height: 32),
            _infoRow(
              icon: Icons.calendar_today,
              label: 'Membro desde',
              value: _userProfile?['created_at'] != null
                  ? _formatDate(_userProfile!['created_at'])
                  : 'Recentemente',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: Colors.pink[400], size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _menuItem(Icons.settings, 'Configurações', () {}),
          const Divider(height: 1, indent: 56),
          _menuItem(Icons.help_outline, 'Central de Ajuda', () {}),
          const Divider(height: 1, indent: 56),
          _menuItem(Icons.privacy_tip_outlined, 'Política de Privacidade', () {}),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.pink[400]),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  String _formatDate(String isoString) {
    final date = DateTime.parse(isoString);
    return '${date.day}/${date.month}/${date.year}';
  }
}