import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/scan_result.dart';
import '../../../models/ingredient.dart';
import '../../chatbot/screens/chatbot_screen.dart';
import '../../../services/tts_service.dart';

class AnalysisScreen extends StatefulWidget {
  final ScanResult result;
  final String preferredLanguage;
  const AnalysisScreen({
    super.key,
    required this.result,
    this.preferredLanguage = 'en',
  });
  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _currentLanguage;
  bool _isSpeaking = false;
  final _tts = TtsService();
  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.preferredLanguage;
    _tabController = TabController(length: 4, vsync: this);
    HapticFeedback.mediumImpact();
    _tts.init(_currentLanguage);
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select language',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              const Text(
                'Affects TTS and chatbot responses',
                style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 16),
              _LangTile(
                flag: '🇬🇧',
                label: 'English',
                selected: _currentLanguage == 'en',
                onTap: () {
                  setState(() => _currentLanguage = 'en');
                  _tts.init('en');
                  Navigator.of(ctx).pop();
                },
              ),
              const SizedBox(height: 8),
              _LangTile(
                flag: '🇮🇳',
                label: 'Hindi',
                selected: _currentLanguage == 'hi',
                onTap: () {
                  setState(() => _currentLanguage = 'hi');
                  _tts.init('hi');
                  Navigator.of(ctx).pop();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tts.stop(); // ADD THIS
    super.dispose();
  }

  Future _toggleTts() async {
    if (_isSpeaking) {
      await _tts.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      final text = '${widget.result.productName}. '
          'Safety score: '
          '${widget.result.overallSafetyScore} out of 100. '
          'Verdict: ${widget.result.verdict}. '
          '${widget.result.summary}';
      await _tts.speak(text);
      if (mounted) setState(() => _isSpeaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.result.productName ?? 'Unknown Product'),
            if (widget.result.brand.isEmpty)
              Text(widget.result.productName ?? 'Unknown Product'),
          ],
        ),
        actions: [
          // Language selector button
          GestureDetector(
            onTap: _showLanguagePicker,
            child: Container(
              margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.subtleLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentLanguage == 'hi' ? '🇮🇳' : '🇬🇧',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _currentLanguage == 'hi' ? 'HI' : 'EN',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF555555),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.green,
          unselectedLabelColor: const Color(0xFF888888),
          indicatorColor: AppColors.green,
          indicatorWeight: 2,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Ingredients'),
            Tab(text: 'Alternatives'),
            Tab(text: 'Regulations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(result: widget.result),
          _IngredientsTab(result: widget.result),
          _AlternativesTab(result: widget.result),
          _RegulationsTab(result: widget.result),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Speaker button — top
          FloatingActionButton.small(
            heroTag: 'speaker',
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.borderLight),
            ),
            onPressed: _toggleTts,
            child: Icon(
              _isSpeaking ? Icons.stop_rounded : Icons.volume_up_outlined,
              color: AppColors.green,
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          // Chat button — bottom
          FloatingActionButton(
            heroTag: 'chat',
            backgroundColor: AppColors.green,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ChatbotScreen(
                  scanContext: widget.result.chatbotContext,
                  productName: widget.result.productName,
                  preferredLanguage: _currentLanguage, // PASS LANGUAGE
                ),
              );
            },
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ─── OVERVIEW TAB ────────────────────────────────────

class _OverviewTab extends StatefulWidget {
  final ScanResult result;
  const _OverviewTab({required this.result});
  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _scoreCtrl;
  late Animation<double> _scoreAnim;

  @override
  void initState() {
    super.initState();
    _scoreCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    _scoreAnim = Tween<double>(
            begin: 0, end: widget.result.overallSafetyScore.toDouble())
        .animate(
            CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOutCubic));
    _scoreCtrl.forward();
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.result.verdict) {
      case 'GREEN':
        return AppColors.green;
      case 'RED':
        return AppColors.red;
      default:
        return AppColors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
// Find this in _OverviewTabState build method and replace the entire Center widget:

        Center(
          child: AnimatedBuilder(
            animation: _scoreAnim,
            builder: (_, __) => SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: _scoreAnim.value / 100,
                      strokeWidth: 10,
                      backgroundColor: _color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(_color),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Score number sits INSIDE the ring
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_scoreAnim.value.toInt()}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          color: _color,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        '/100',
                        style: TextStyle(
                          color: _color.withValues(alpha: 0.6),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 20),
        _TrafficLight(verdict: widget.result.verdict),
        const SizedBox(height: 16),
        _VerdictBanner(verdict: widget.result.verdict),
        const SizedBox(height: 20),
        if (widget.result.allergenAlerts.isNotEmpty)
          ...widget.result.allergenAlerts.map(
            (a) => _AlertCard(
              icon: Icons.warning_amber_rounded,
              color: AppColors.red,
              title: 'Allergen: ${a['allergen'] ?? ''}',
              subtitle: 'Found in ${a['found_in'] ?? ''}',
            ),
          ),
        if (widget.result.pregnancyAssessment != null &&
            widget.result.pregnancyAssessment!['is_safe'] == false)
          _AlertCard(
            icon: Icons.pregnant_woman_outlined,
            color: AppColors.red,
            title: 'Not safe during pregnancy',
            subtitle:
                widget.result.pregnancyAssessment!['reason'] as String? ?? '',
          ),
        if (widget.result.babyAssessment != null &&
            widget.result.babyAssessment!['is_safe'] == false)
          _AlertCard(
            icon: Icons.child_care_outlined,
            color: AppColors.red,
            title: 'Not safe for infants',
            subtitle: widget.result.babyAssessment!['reason'] as String? ?? '',
          ),
        if (widget.result.personalizedRisks.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Personalised risks',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...widget.result.personalizedRisks.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.circle, size: 6, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(r, style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.subtleLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Summary', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(widget.result.summary,
                  style: const TextStyle(fontSize: 13, height: 1.6)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrafficLight extends StatelessWidget {
  final String verdict;
  const _TrafficLight({required this.verdict});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Light(color: AppColors.red, active: verdict == 'RED', label: 'Avoid'),
        const SizedBox(width: 16),
        _Light(
            color: AppColors.amber,
            active: verdict == 'YELLOW',
            label: 'Caution'),
        const SizedBox(width: 16),
        _Light(
            color: AppColors.green, active: verdict == 'GREEN', label: 'Safe'),
      ],
    );
  }
}

class _Light extends StatelessWidget {
  final Color color;
  final bool active;
  final String label;
  const _Light(
      {required this.color, required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: active ? 48 : 36,
        height: active ? 48 : 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? color : color.withValues(alpha: 0.2),
          boxShadow: active
              ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 12)]
              : null,
        ),
      ),
      const SizedBox(height: 4),
      Text(label,
          style: TextStyle(
              fontSize: 11,
              color: active ? color : const Color(0xFFBBBBBB),
              fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
    ]);
  }
}

class _VerdictBanner extends StatelessWidget {
  final String verdict;
  const _VerdictBanner({required this.verdict});

  @override
  Widget build(BuildContext context) {
    final (color, icon, text) = switch (verdict) {
      'GREEN' => (AppColors.green, Icons.check_circle_outline, 'Safe to use'),
      'RED' => (AppColors.red, Icons.cancel_outlined, 'Avoid this product'),
      _ => (AppColors.amber, Icons.warning_amber_outlined, 'Use with caution'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 10),
          Text(
            text.toUpperCase(),
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.5),
          ),
        ],
      ),
    )
        .animate()
        .scale(
            begin: const Offset(0.85, 0.85),
            curve: Curves.easeOutBack,
            duration: 400.ms)
        .fadeIn(duration: 300.ms);
  }
}

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _AlertCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: color)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF555555))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── INGREDIENTS TAB ─────────────────────────────────

class _IngredientsTab extends StatelessWidget {
  final ScanResult result;
  const _IngredientsTab({required this.result});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (result.disguisedIngredientsSummary.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.redLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.masks_outlined, color: AppColors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${result.disguisedIngredientsSummary.length} disguised ingredient(s) detected',
                  style: const TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
            ]),
          ).animate().shake(duration: 600.ms),
        Text(
          'Ingredients (${result.ingredients.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        ...result.ingredients.asMap().entries.map(
              (e) => _IngredientCard(ingredient: e.value)
                  .animate(delay: (e.key * 40).ms)
                  .slideX(begin: -0.15)
                  .fadeIn(),
            ),
        if (result.labelHonestyIssues.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Label honesty — ${result.labelHonestyScore}/100',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...result.labelHonestyIssues.map(
            (issue) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _SeverityBadge(
                        severity: issue['severity'] as String? ?? 'LOW'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Claim: "${issue['claim']}"',
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 12),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Text(
                    'Reality: ${issue['reality']}',
                    style: const TextStyle(fontSize: 12, color: AppColors.red),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  const _IngredientCard({required this.ingredient});

  Color get _borderColor {
    switch (ingredient.safetyLabel) {
      case 'RED':
        return AppColors.red;
      case 'GREEN':
        return AppColors.green;
      default:
        return AppColors.amber;
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(ingredient.canonicalName,
                style: Theme.of(context).textTheme.headlineMedium),
            if (ingredient.isDisguised) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.redLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Listed as "${ingredient.ocrName}"\nTrue identity: ${ingredient.trueChemicalName}',
                  style: const TextStyle(color: AppColors.red, fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _DetailRow('Chemical formula', ingredient.trueChemicalName ?? '-'),
            _DetailRow('Formulation', ingredient.formulation),
            _DetailRow('Health impact', ingredient.healthImpact),
            _DetailRow('Why it is used', ingredient.usageReason),
            _DetailRow('Sustainability', ingredient.sustainabilityNote),
            const SizedBox(height: 12),
            Text('Regulatory status',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _RegRow('🇮🇳 India (FSSAI)', ingredient.regulationIN),
            _RegRow('🇺🇸 USA (FDA)', ingredient.regulationUS),
            _RegRow('🇪🇺 EU (EFSA)', ingredient.regulationEU),
            _RegRow('🌐 WHO', ingredient.regulationWHO),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: _borderColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ingredient.canonicalName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  if (ingredient.isDisguised)
                    Text('Listed as: ${ingredient.ocrName}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF888888))),
                ],
              ),
            ),
            if (ingredient.isDisguised) _Badge('DISGUISED', AppColors.red),
            if (ingredient.allergen) ...[
              const SizedBox(width: 4),
              _Badge(ingredient.allergenType ?? 'ALLERGEN', AppColors.amber),
            ],
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFBBBBBB), size: 20),
          ]),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final String severity;
  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = severity == 'HIGH'
        ? AppColors.red
        : severity == 'MEDIUM'
            ? AppColors.amber
            : Colors.grey;
    return _Badge(severity, color);
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Color(0xFF888888))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _RegRow extends StatelessWidget {
  final String region, status;
  const _RegRow(this.region, this.status);

  Color get _color {
    final s = status.toLowerCase();
    if (s.contains('banned') || s.contains('prohibited')) return AppColors.red;
    if (s.contains('restrict') || s.contains('limited')) return AppColors.amber;
    if (s.contains('approved') || s.contains('gras') || s.contains('permitted'))
      return AppColors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(
            width: 120,
            child: Text(region, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(status,
                style: TextStyle(
                    color: _color, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ),
      ]),
    );
  }
}

// ─── ALTERNATIVES TAB ────────────────────────────────

class _AlternativesTab extends StatelessWidget {
  final ScanResult result;
  const _AlternativesTab({required this.result});

  @override
  Widget build(BuildContext context) {
    if (result.alternatives.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.find_replace_outlined,
                size: 64, color: Color(0xFFBBBBBB)),
            SizedBox(height: 16),
            Text('No safer alternatives found',
                style: TextStyle(color: Color(0xFF888888))),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Better options for you',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        const Text('All scored higher than this product',
            style: TextStyle(fontSize: 12, color: Color(0xFF888888))),
        const SizedBox(height: 16),
        ...result.alternatives.asMap().entries.map(
              (e) => _AlternativeCard(product: e.value)
                  .animate(delay: (e.key * 80).ms)
                  .slideY(begin: 0.3)
                  .fadeIn(),
            ),
      ],
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _AlternativeCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final score = product['safety_score'] as int? ?? 0;
    final color = score >= 70
        ? AppColors.green
        : score >= 40
            ? AppColors.amber
            : AppColors.red;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(children: [
        if (product['image_url'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product['image_url'] as String,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.subtleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image_not_supported_outlined,
                    color: Color(0xFFBBBBBB)),
              ),
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['product_name'] as String? ?? '',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                product['brand'] as String? ?? '',
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$score/100',
                  style: TextStyle(
                      color: color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── REGULATIONS TAB ─────────────────────────────────

class _RegulationsTab extends StatelessWidget {
  final ScanResult result;
  const _RegulationsTab({required this.result});

  @override
  Widget build(BuildContext context) {
    final flagged =
        result.ingredients.where((i) => i.safetyLabel != 'GREEN').toList();
    final sustain = result.sustainability;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Global regulatory status',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (flagged.isEmpty)
          const Text('No flagged ingredients.',
              style: TextStyle(color: AppColors.green)),
        ...flagged.map(
          (ing) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ing.canonicalName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 10),
                _RegRow('🇮🇳 India', ing.regulationIN),
                _RegRow('🇺🇸 USA', ing.regulationUS),
                _RegRow('🇪🇺 EU', ing.regulationEU),
                _RegRow('🌐 WHO', ing.regulationWHO),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Sustainability', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SustainBadge('Score', '${sustain['score'] ?? 0}/100'),
                _SustainBadge('Carbon',
                    sustain['carbon_footprint_level'] as String? ?? '-'),
                _SustainBadge(
                    'Recyclable',
                    sustain['recyclable_packaging'] == null
                        ? '?'
                        : (sustain['recyclable_packaging'] as bool)
                            ? 'Yes'
                            : 'No'),
                _SustainBadge(
                    'Vegan',
                    sustain['vegan'] == null
                        ? '?'
                        : (sustain['vegan'] as bool)
                            ? 'Yes'
                            : 'No'),
              ],
            ),
            if ((sustain['sustainability_notes'] as String? ?? '')
                .isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                sustain['sustainability_notes'] as String,
                style: const TextStyle(fontSize: 13, height: 1.6),
              ),
            ],
          ]),
        ),
      ],
    );
  }
}

class _SustainBadge extends StatelessWidget {
  final String label, value;
  const _SustainBadge(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
    ]);
  }
}

class _LangTile extends StatelessWidget {
  final String flag, label;
  final bool selected;
  final VoidCallback onTap;
  const _LangTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenLight : AppColors.subtleLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.borderLight,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppColors.green : const Color(0xFF333333),
              )),
          const Spacer(),
          if (selected)
            const Icon(Icons.check_circle_rounded,
                color: AppColors.green, size: 18),
        ]),
      ),
    );
  }
}
