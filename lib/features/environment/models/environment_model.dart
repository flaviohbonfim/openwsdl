import 'dart:convert';

class Environment {
  final String id;
  final String name;
  final List<EnvironmentVariable> variables;
  final DateTime createdAt;
  final DateTime updatedAt;

  Environment({
    required this.id,
    required this.name,
    required this.variables,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Environment copyWith({
    String? name,
    List<EnvironmentVariable>? variables,
  }) {
    return Environment(
      id: id,
      name: name ?? this.name,
      variables: variables ?? List.from(this.variables),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'variables': variables.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Environment.fromMap(Map<String, dynamic> map) {
    return Environment(
      id: map['id'],
      name: map['name'],
      variables: List<EnvironmentVariable>.from(
        map['variables']?.map((x) => EnvironmentVariable.fromMap(x)) ?? [],
      ),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Environment.fromJson(String source) => Environment.fromMap(json.decode(source));
}

class EnvironmentVariable {
  final String key;
  final String value;
  final bool enabled;

  EnvironmentVariable({
    required this.key,
    required this.value,
    this.enabled = true,
  });

  EnvironmentVariable copyWith({
    String? key,
    String? value,
    bool? enabled,
  }) {
    return EnvironmentVariable(
      key: key ?? this.key,
      value: value ?? this.value,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'value': value,
      'enabled': enabled,
    };
  }

  factory EnvironmentVariable.fromMap(Map<String, dynamic> map) {
    return EnvironmentVariable(
      key: map['key'],
      value: map['value'],
      enabled: map['enabled'] ?? true,
    );
  }
}
