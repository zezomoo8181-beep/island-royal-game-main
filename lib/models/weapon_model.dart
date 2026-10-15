class WeaponModel {
  final String id;
  final String name;
  final String type; // pistol | shotgun | assault_rifle | sniper
  final int damage;
  final int maxAmmo;
  final int currentAmmo;
  final double range;
  final double fireRate; // shots per second
  final bool isAutomatic;

  const WeaponModel({
    required this.id,
    required this.name,
    required this.type,
    required this.damage,
    required this.maxAmmo,
    required this.currentAmmo,
    required this.range,
    required this.fireRate,
    required this.isAutomatic,
  });

  static const Map<String, WeaponModel> catalog = {
    'pistol': WeaponModel(
      id: 'pistol',
      name: 'M9 Pistol',
      type: 'pistol',
      damage: 25,
      maxAmmo: 12,
      currentAmmo: 12,
      range: 200,
      fireRate: 3.0,
      isAutomatic: false,
    ),
    'shotgun': WeaponModel(
      id: 'shotgun',
      name: 'S686 Shotgun',
      type: 'shotgun',
      damage: 50,
      maxAmmo: 6,
      currentAmmo: 6,
      range: 120,
      fireRate: 1.0,
      isAutomatic: false,
    ),
    'assault_rifle': WeaponModel(
      id: 'assault_rifle',
      name: 'M416 AR',
      type: 'assault_rifle',
      damage: 35,
      maxAmmo: 30,
      currentAmmo: 30,
      range: 350,
      fireRate: 8.0,
      isAutomatic: true,
    ),
    'sniper': WeaponModel(
      id: 'sniper',
      name: 'Kar98k',
      type: 'sniper',
      damage: 95,
      maxAmmo: 5,
      currentAmmo: 5,
      range: 600,
      fireRate: 0.7,
      isAutomatic: false,
    ),
  };

  WeaponModel copyWith({int? currentAmmo}) => WeaponModel(
        id: id,
        name: name,
        type: type,
        damage: damage,
        maxAmmo: maxAmmo,
        currentAmmo: currentAmmo ?? this.currentAmmo,
        range: range,
        fireRate: fireRate,
        isAutomatic: isAutomatic,
      );
}
