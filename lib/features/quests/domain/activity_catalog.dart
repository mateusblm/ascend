class ActivityMetricDefinition {
  const ActivityMetricDefinition({
    required this.id,
    required this.type,
    required this.unit,
    required this.required,
    required this.derived,
    required this.minimum,
    required this.maximum,
    required this.evolution,
  });

  final String id;
  final String type;
  final String unit;
  final bool required;
  final bool derived;
  final double minimum;
  final double maximum;
  final String evolution;

  factory ActivityMetricDefinition.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final type = json['tipo'];
    final unit = json['unidade'];
    final minimum = json['minimo'];
    final maximum = json['maximo'];
    if (id is! String ||
        id.isEmpty ||
        type is! String ||
        unit is! String ||
        minimum is! num ||
        maximum is! num ||
        minimum > maximum) {
      throw const FormatException('Definição de métrica inválida.');
    }
    return ActivityMetricDefinition(
      id: id,
      type: type,
      unit: unit,
      required: json['obrigatoria'] == true,
      derived: json['calculada'] == true,
      minimum: minimum.toDouble(),
      maximum: maximum.toDouble(),
      evolution: json['evolucao'] as String? ?? 'INFORMATIONAL',
    );
  }
}

class ActivityDefinition {
  const ActivityDefinition({
    required this.id,
    required this.name,
    required this.executionType,
    required this.schemaVersion,
    required this.isCustom,
    required this.attributeDistribution,
    required this.metrics,
  });

  final String id;
  final String name;
  final String executionType;
  final int schemaVersion;
  final bool isCustom;
  final Map<String, int> attributeDistribution;
  final List<ActivityMetricDefinition> metrics;

  factory ActivityDefinition.fromJson(Map<String, dynamic> json) {
    final distribution = json['distribuicaoAtributos'];
    final metrics = json['metricas'];
    if (json['id'] is! String ||
        json['nome'] is! String ||
        json['modeloExecucao'] is! String ||
        json['versaoSchema'] is! num ||
        distribution is! Map ||
        metrics is! List) {
      throw const FormatException('Atividade inválida no catálogo.');
    }
    final parsedDistribution = Map<String, int>.fromEntries(
      distribution.entries
          .where((entry) => entry.key is String && entry.value is num)
          .map(
            (entry) =>
                MapEntry(entry.key as String, (entry.value as num).toInt()),
          ),
    );
    if (parsedDistribution.values.any((weight) => weight < 0) ||
        parsedDistribution.values.fold<int>(0, (sum, value) => sum + value) !=
            100) {
      throw const FormatException('Distribuição de atributos inválida.');
    }
    return ActivityDefinition(
      id: json['id'] as String,
      name: json['nome'] as String,
      executionType: json['modeloExecucao'] as String,
      schemaVersion: (json['versaoSchema'] as num).toInt(),
      isCustom: json['personalizada'] == true,
      attributeDistribution: Map.unmodifiable(parsedDistribution),
      metrics: metrics
          .whereType<Map>()
          .map(
            (metric) => ActivityMetricDefinition.fromJson(
              Map<String, dynamic>.from(metric),
            ),
          )
          .toList(growable: false),
    );
  }
}

class ActivityModality {
  const ActivityModality({
    required this.id,
    required this.name,
    required this.activities,
  });
  final String id;
  final String name;
  final List<ActivityDefinition> activities;

  factory ActivityModality.fromJson(Map<String, dynamic> json) {
    final activities = json['atividades'];
    if (json['id'] is! String ||
        json['nome'] is! String ||
        activities is! List) {
      throw const FormatException('Modalidade inválida no catálogo.');
    }
    return ActivityModality(
      id: json['id'] as String,
      name: json['nome'] as String,
      activities: activities
          .whereType<Map>()
          .map(
            (item) =>
                ActivityDefinition.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
    );
  }
}

class ActivityCategory {
  const ActivityCategory({
    required this.id,
    required this.name,
    required this.modalities,
  });
  final String id;
  final String name;
  final List<ActivityModality> modalities;

  factory ActivityCategory.fromJson(Map<String, dynamic> json) {
    final modalities = json['modalidades'];
    if (json['id'] is! String ||
        json['nome'] is! String ||
        modalities is! List) {
      throw const FormatException('Categoria inválida no catálogo.');
    }
    return ActivityCategory(
      id: json['id'] as String,
      name: json['nome'] as String,
      modalities: modalities
          .whereType<Map>()
          .map(
            (item) =>
                ActivityModality.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
    );
  }
}

class ActivityCatalog {
  const ActivityCatalog({required this.version, required this.categories});
  final int version;
  final List<ActivityCategory> categories;

  factory ActivityCatalog.fromJson(Map<String, dynamic> json) {
    final categories = json['categorias'];
    if (json['versao'] is! num || categories is! List) {
      throw const FormatException('Catálogo de atividades inválido.');
    }
    return ActivityCatalog(
      version: (json['versao'] as num).toInt(),
      categories: categories
          .whereType<Map>()
          .map(
            (item) =>
                ActivityCategory.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
    );
  }

  ActivityDefinition? findActivity(String id) {
    for (final category in categories) {
      for (final modality in category.modalities) {
        for (final activity in modality.activities) {
          if (activity.id == id) return activity;
        }
      }
    }
    return null;
  }
}
