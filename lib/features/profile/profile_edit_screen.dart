// プロフィール編集画面。表示名の変更とプリセットアバターの選択を行う。
// 保存すると users テーブルの name / icon_url を更新する。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/supabase_client.dart';
import 'profile_avatars.dart';
import 'profile_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  static const _pink = Color(0xFFEC407A);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedKey = presetAvatars.first.key;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final profile = await ref.read(myProfileProvider.future);
      if (!mounted) return;
      setState(() {
        _nameController.text = profile?.name ?? '';
        _selectedKey = presetAvatarFor(profile?.iconUrl).key;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = 'プロフィールの取得に失敗: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) context.go('/login');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await updateProfile(
        userId: user.id,
        name: _nameController.text.trim(),
        iconUrl: _selectedKey,
      );
      ref.invalidate(myProfileProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('プロフィールを保存しました')),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存に失敗しました。もう一度お試しください。')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F9),
      appBar: AppBar(
        title: const Text('プロフィール'),
        backgroundColor: _pink,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _pink));
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _loadError!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final selected = presetAvatarFor(_selectedKey);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: PresetAvatarView(avatar: selected, size: 108)),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _nameController.text.trim().isEmpty
                        ? '名前を入力してください'
                        : _nameController.text.trim(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _Card(
                  title: 'アバター',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final avatar in presetAvatars)
                        _AvatarChoice(
                          avatar: avatar,
                          isSelected: avatar.key == _selectedKey,
                          onTap: () =>
                              setState(() => _selectedKey = avatar.key),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Card(
                  title: '表示名',
                  child: TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.done,
                    // 上部のプレビュー名を入力に合わせて更新する。
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) => _save(),
                    decoration: InputDecoration(
                      hintText: '名前',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: _pink.withValues(alpha: 0.25),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: _pink.withValues(alpha: 0.25),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _pink, width: 2),
                      ),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? '名前を入力してください'
                        : null,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pink,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _pink.withValues(alpha: 0.4),
                      disabledForegroundColor: Colors.white70,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '保存する',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 見出し付きの白カード。設定項目のまとまりを表す。
class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEC407A).withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// アバター1件の選択肢。選択中はピンクのリングとチェックを表示する。
class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.avatar,
    required this.isSelected,
    required this.onTap,
  });

  static const _pink = Color(0xFFEC407A);

  final PresetAvatar avatar;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? _pink : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: PresetAvatarView(avatar: avatar, size: 64),
              ),
              if (isSelected)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _pink,
                    ),
                    child: const Icon(Icons.check,
                        size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            avatar.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? _pink : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
