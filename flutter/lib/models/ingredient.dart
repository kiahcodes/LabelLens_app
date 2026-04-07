class Ingredient {
  final String ocrName;
  final String canonicalName;
  final bool isDisguised;
  final String? trueChemicalName;
  final String? disguiseExplanation;
  final String safetyLabel;
  final int safetyScore;
  final bool pregnancyRisk;
  final bool babyRisk;
  final bool allergen;
  final String? allergenType;
  final String formulation;
  final String healthImpact;
  final String usageReason;
  final String regulationIN;
  final String regulationUS;
  final String regulationEU;
  final String regulationWHO;
  final String sustainabilityNote;

  const Ingredient({
    required this.ocrName,
    required this.canonicalName,
    required this.isDisguised,
    this.trueChemicalName,
    this.disguiseExplanation,
    required this.safetyLabel,
    required this.safetyScore,
    required this.pregnancyRisk,
    required this.babyRisk,
    required this.allergen,
    this.allergenType,
    required this.formulation,
    required this.healthImpact,
    required this.usageReason,
    required this.regulationIN,
    required this.regulationUS,
    required this.regulationEU,
    required this.regulationWHO,
    required this.sustainabilityNote,
  });

  factory Ingredient.fromJson(Map j) => Ingredient(
        ocrName: j['ocr_name'] as String? ?? '',
        canonicalName: j['canonical_name'] as String? ?? '',
        isDisguised: j['is_disguised'] as bool? ?? false,
        trueChemicalName: j['true_chemical_name'] as String?,
        disguiseExplanation: j['disguise_explanation'] as String?,
        safetyLabel: j['safety_label'] as String? ?? 'YELLOW',
        safetyScore: j['safety_score'] as int? ?? 50,
        pregnancyRisk: j['pregnancy_risk'] as bool? ?? false,
        babyRisk: j['baby_risk'] as bool? ?? false,
        allergen: j['allergen'] as bool? ?? false,
        allergenType: j['allergen_type'] as String?,
        formulation: j['formulation'] as String? ?? '',
        healthImpact: j['health_impact'] as String? ?? '',
        usageReason: j['usage_reason'] as String? ?? '',
        regulationIN: j['regulation_IN'] as String? ?? '',
        regulationUS: j['regulation_US'] as String? ?? '',
        regulationEU: j['regulation_EU'] as String? ?? '',
        regulationWHO: j['regulation_WHO'] as String? ?? '',
        sustainabilityNote: j['sustainability_note'] as String? ?? '',
      );
}
