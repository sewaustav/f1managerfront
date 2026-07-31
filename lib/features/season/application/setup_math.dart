class SetupValues {
  const SetupValues({
    this.aeroDynamic = 0,
    this.engine = 0,
    this.chassis = 0,
    this.floor = 0,
    this.tyres = 0,
    this.reliability = 0,
    this.settingsAngle = 0,
  });

  final int aeroDynamic, engine, chassis, floor, tyres, reliability, settingsAngle;

  SetupValues copyWith({
    int? aeroDynamic,
    int? engine,
    int? chassis,
    int? floor,
    int? tyres,
    int? reliability,
    int? settingsAngle,
  }) =>
      SetupValues(
        aeroDynamic: aeroDynamic ?? this.aeroDynamic,
        engine: engine ?? this.engine,
        chassis: chassis ?? this.chassis,
        floor: floor ?? this.floor,
        tyres: tyres ?? this.tyres,
        reliability: reliability ?? this.reliability,
        settingsAngle: settingsAngle ?? this.settingsAngle,
      );
}

int setupSpent(SetupValues v) =>
    v.aeroDynamic + v.engine + v.chassis + v.floor + v.tyres + v.reliability;

int setupRemaining(SetupValues v, int pool) => pool - setupSpent(v);

bool setupValid(SetupValues v, int pool) => setupSpent(v) <= pool;
