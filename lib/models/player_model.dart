import 'package:equatable/equatable.dart';

class PlayerModel extends Equatable {
  final String id;
  final String name;
  final double x;
  final double y;
  final double aimX;
  final double aimY;
  final int health;
  final int armor;
  final String weapon;
  final bool isDead;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    this.aimX = 1.0,
    this.aimY = 0.0,
    this.health = 100,
    this.armor = 0,
    this.weapon = 'assault_rifle',
    this.isDead = false,
  });

  PlayerModel copyWith({
    String? id,
    String? name,
    double? x,
    double? y,
    double? aimX,
    double? aimY,
    int? health,
    int? armor,
    String? weapon,
    bool? isDead,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      aimX: aimX ?? this.aimX,
      aimY: aimY ?? this.aimY,
      health: health ?? this.health,
      armor: armor ?? this.armor,
      weapon: weapon ?? this.weapon,
      isDead: isDead ?? this.isDead,
    );
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Player',
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      aimX: (json['aimX'] as num?)?.toDouble() ?? 1.0,
      aimY: (json['aimY'] as num?)?.toDouble() ?? 0.0,
      health: json['hp'] as int? ?? 100,
      armor: json['armor'] as int? ?? 0,
      weapon: json['weapon'] as String? ?? 'assault_rifle',
      isDead: json['isDead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'x': x,
        'y': y,
        'aimX': aimX,
        'aimY': aimY,
        'hp': health,
        'armor': armor,
        'weapon': weapon,
        'isDead': isDead,
      };

  @override
  List<Object?> get props =>
      [id, name, x, y, aimX, aimY, health, armor, weapon, isDead];
}
