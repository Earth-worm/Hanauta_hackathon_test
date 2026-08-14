// プリセットアバターの定義と表示ウィジェット。
// 画像ファイルを持たず、グラデーション＋アイコンで描画する。

import 'package:flutter/material.dart';

// 選べるアバター1種類ぶんの定義。icon_url には key を保存する。
class PresetAvatar {
  const PresetAvatar({
    required this.key,
    required this.label,
    required this.icon,
    required this.colors,
  });

  final String key;
  final String label;
  final IconData icon;
  final List<Color> colors;
}

const presetAvatars = <PresetAvatar>[
  PresetAvatar(
    key: 'preset:1',
    label: 'フラワー',
    icon: Icons.local_florist,
    colors: [Color(0xFFEC407A), Color(0xFFF06292)],
  ),
  PresetAvatar(
    key: 'preset:2',
    label: 'キラキラ',
    icon: Icons.auto_awesome,
    colors: [Color(0xFF2ECDB0), Color(0xFF4DD0C4)],
  ),
  PresetAvatar(
    key: 'preset:3',
    label: 'ハート',
    icon: Icons.favorite,
    colors: [Color(0xFF5C6BC0), Color(0xFF7986CB)],
  ),
];

// icon_url からアバター定義を引く。未設定・不明な値なら先頭を返す。
PresetAvatar presetAvatarFor(String? iconUrl) {
  return presetAvatars.firstWhere(
    (avatar) => avatar.key == iconUrl,
    orElse: () => presetAvatars.first,
  );
}

// プリセットアバターを丸く表示する。size でアイコンごと拡大縮小する。
class PresetAvatarView extends StatelessWidget {
  const PresetAvatarView({
    super.key,
    required this.avatar,
    this.size = 56,
  });

  final PresetAvatar avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: avatar.colors,
        ),
      ),
      child: Icon(avatar.icon, color: Colors.white, size: size * 0.5),
    );
  }
}
