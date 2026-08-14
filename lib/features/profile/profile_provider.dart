// プロフィール編集画面のデータ取得・更新を担当するProvider群。
// users テーブルから自分の行を読み、名前とアバターを更新する。

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase_client.dart';
import '../../models/app_user.dart';

// ログイン中ユーザーのプロフィール。未ログイン・未登録なら null。
final myProfileProvider = FutureProvider<AppUser?>((ref) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return null;

  final row =
      await supabase.from('users').select().eq('id', userId).maybeSingle();
  if (row == null) return null;

  return AppUser.fromJson(row);
});

// 名前とアバター（icon_url）を更新する。updated_at はDB側のトリガで自動更新される。
Future<void> updateProfile({
  required String userId,
  required String name,
  required String iconUrl,
}) async {
  await supabase
      .from('users')
      .update({'name': name, 'icon_url': iconUrl}).eq('id', userId);
}
