import 'ingredient.dart';

class ScanResult {
  final String scanId;
  final String productName;
  final String brand;
  final String productType;
  final int overallSafetyScore;
  final String verdict;
  final int labelHonestyScore;
  final List<Map<String, dynamic>> labelHonestyIssues;
  final List<Ingredient> ingredients;
  final List<Map<String, dynamic>> disguisedIngredientsSummary;
  final List<String> personalizedRisks;
  final Map<String, dynamic>? pregnancyAssessment;
  final Map<String, dynamic>? babyAssessment;
  final List<Map<String, dynamic>> allergenAlerts;
  final Map<String, dynamic> sustainability;
  final String summary;
  final String chatbotContext;
  final List<Map<String, dynamic>> alternatives;

  const ScanResult({
    required this.scanId,
    required this.productName,
    required this.brand,
    required this.productType,
    required this.overallSafetyScore,
    required this.verdict,
    required this.labelHonestyScore,
    required this.labelHonestyIssues,
    required this.ingredients,
    required this.disguisedIngredientsSummary,
    required this.personalizedRisks,
    this.pregnancyAssessment,
    this.babyAssessment,
    required this.allergenAlerts,
    required this.sustainability,
    required this.summary,
    required this.chatbotContext,
    required this.alternatives,
  });

  factory ScanResult.fromJson(Map<String, dynamic> j) => ScanResult(
        scanId: j['scan_id'] as String? ?? '',
        productName: j['product_name'] as String? ?? 'Unknown Product',
        brand: j['brand'] as String? ?? '',
        productType: j['product_type'] as String? ?? 'food',
        overallSafetyScore: j['overall_safety_score'] as int? ?? 50,
        verdict: j['verdict'] as String? ?? 'YELLOW',
        labelHonestyScore: j['label_honesty_score'] as int? ?? 50,
        labelHonestyIssues: List<Map<String, dynamic>>.from(
            j['label_honesty_issues'] as List? ?? []),
        ingredients: (j['ingredients'] as List? ?? [])
            .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
            .toList(),
        disguisedIngredientsSummary: List<Map<String, dynamic>>.from(
            j['disguised_ingredients_summary'] as List? ?? []),
        personalizedRisks:
            List<String>.from(j['personalized_risks'] as List? ?? []),
        pregnancyAssessment: j['pregnancy_assessment'] as Map<String, dynamic>?,
        babyAssessment: j['baby_assessment'] as Map<String, dynamic>?,
        allergenAlerts: List<Map<String, dynamic>>.from(
            j['allergen_alerts'] as List? ?? []),
        sustainability: j['sustainability'] as Map<String, dynamic>? ?? {},
        summary: j['summary'] as String? ?? '',
        chatbotContext: j['chatbot_context'] as String? ?? '',
        alternatives:
            List<Map<String, dynamic>>.from(j['alternatives'] as List? ?? []),
      );
}
