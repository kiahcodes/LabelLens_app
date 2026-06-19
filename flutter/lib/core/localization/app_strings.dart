class AppStrings {
  final String languageCode;

  const AppStrings(this.languageCode);

  bool get isHindi => languageCode == 'hi';

  String get appTitle => 'LabelLens';
  String get goodMorning => isHindi ? 'सुप्रभात' : 'Good morning';
  String get goodAfternoon => isHindi ? 'नमस्ते' : 'Good afternoon';
  String get goodEvening => isHindi ? 'शुभ संध्या' : 'Good evening';
  String get there => isHindi ? 'दोस्त' : 'there';
  String greeting(String greeting, String name) => '$greeting, $name';

  String get pregnancyModeOn =>
      isHindi ? 'गर्भावस्था मोड चालू' : 'Pregnancy mode ON';
  String get babyModeOn => isHindi ? 'बेबी मोड चालू' : 'Baby mode ON';
  String get newScan => isHindi ? 'नया स्कैन' : 'New scan';
  String get scanAProduct => isHindi ? 'प्रोडक्ट स्कैन करें' : 'Scan a product';
  String scans(int count) => isHindi ? '$count स्कैन' : '$count scans';
  String get history => isHindi ? 'इतिहास' : 'History';
  String get recentScans => isHindi ? 'हाल के स्कैन' : 'Recent scans';
  String get seeAll => isHindi ? 'सभी देखें' : 'See all';
  String peopleScannedRecently({
    required Object count,
    required Object productName,
  }) {
    if (isHindi) return '$count लोगों ने हाल ही में $productName स्कैन किया';
    return '$count people scanned $productName recently';
  }

  String get noScansYet => isHindi ? 'अभी कोई स्कैन नहीं' : 'No scans yet';
  String get tapNewScan => isHindi
      ? 'पहला प्रोडक्ट जांचने के लिए नया स्कैन दबाएं'
      : 'Tap New scan to analyse your first product';
  String get unknown => isHindi ? 'अज्ञात' : 'Unknown';
  String get couldNotLoadScan =>
      isHindi ? 'स्कैन लोड नहीं हो सका' : 'Could not load scan';

  String verdictLabel(String verdict) {
    switch (verdict) {
      case 'GREEN':
        return isHindi ? 'सुरक्षित' : 'Safe';
      case 'RED':
        return isHindi ? 'बचें' : 'Avoid';
      default:
        return isHindi ? 'सावधानी' : 'Caution';
    }
  }

  String get myProfile => isHindi ? 'मेरी प्रोफाइल' : 'My profile';
  String get save => isHindi ? 'सेव करें' : 'Save';
  String get profileUpdated =>
      isHindi ? 'प्रोफाइल अपडेट हो गई!' : 'Profile updated!';
  String saveFailed(Object error) =>
      isHindi ? 'सेव नहीं हुआ: $error' : 'Save failed: $error';
  String get personalInfo => isHindi ? 'निजी जानकारी' : 'Personal info';
  String get name => isHindi ? 'नाम' : 'Name';
  String get healthModes => isHindi ? 'हेल्थ मोड' : 'Health modes';
  String get pregnancyMode => isHindi ? 'गर्भावस्था मोड' : 'Pregnancy mode';
  String get babyMode => isHindi ? 'बेबी मोड' : 'Baby mode';
  String get knownAllergies => isHindi ? 'ज्ञात एलर्जी' : 'Known allergies';
  String get language => isHindi ? 'भाषा' : 'Language';
  String get english => isHindi ? 'अंग्रेजी' : 'English';
  String get hindi => isHindi ? 'हिंदी' : 'Hindi';
  String get selectLanguage => isHindi ? 'भाषा चुनें' : 'Select language';
  String get languageAffectsVoiceAndChat => isHindi
      ? 'यह वॉइस और चैटबॉट जवाबों पर लागू होगा'
      : 'Affects TTS and chatbot responses';
  String get logOut => isHindi ? 'लॉग आउट' : 'Log out';
  String get deleteAccount => isHindi ? 'अकाउंट हटाएं' : 'Delete account';
  String get deleting => isHindi ? 'हटाया जा रहा है...' : 'Deleting...';
  String get deleteAccountQuestion =>
      isHindi ? 'अकाउंट हटाएं?' : 'Delete account?';
  String get deleteAccountWarning => isHindi
      ? 'यह आपका अकाउंट, प्रोफाइल, स्कैन इतिहास और नोटिफिकेशन स्थायी रूप से हटा देगा। इसे वापस नहीं किया जा सकता।'
      : 'This permanently deletes your account, profile, scan history, and notifications. This cannot be undone.';
  String get cancel => isHindi ? 'रद्द करें' : 'Cancel';
  String get notSignedIn =>
      isHindi ? 'आप साइन इन नहीं हैं।' : 'You are not signed in.';
  String deleteFailed(Object error) =>
      isHindi ? 'हटाना विफल: $error' : 'Delete failed: $error';
  String get requestFailed => isHindi ? 'रिक्वेस्ट विफल' : 'Request failed';

  String allergy(String value) {
    if (!isHindi) return value;
    return switch (value) {
      'Gluten' => 'ग्लूटेन',
      'Dairy' => 'डेयरी',
      'Eggs' => 'अंडे',
      'Nuts' => 'मेवे',
      'Peanuts' => 'मूंगफली',
      'Soy' => 'सोया',
      'Fish' => 'मछली',
      'Shellfish' => 'शेलफिश',
      'Sesame' => 'तिल',
      _ => value,
    };
  }

  String get unknownProduct => isHindi ? 'अज्ञात प्रोडक्ट' : 'Unknown Product';
  String get safetyScore => isHindi ? 'सुरक्षा स्कोर' : 'Safety score';
  String get verdict => isHindi ? 'निर्णय' : 'Verdict';
  String get overview => isHindi ? 'सारांश' : 'Overview';
  String get ingredients => isHindi ? 'सामग्री' : 'Ingredients';
  String get alternatives => isHindi ? 'विकल्प' : 'Alternatives';
  String get regulations => isHindi ? 'नियम' : 'Regulations';
  String get allergen => isHindi ? 'एलर्जी' : 'Allergen';
  String get foundIn => isHindi ? 'इसमें मिला' : 'Found in';
  String get notSafeDuringPregnancy =>
      isHindi ? 'गर्भावस्था में सुरक्षित नहीं' : 'Not safe during pregnancy';
  String get notSafeForInfants =>
      isHindi ? 'शिशुओं के लिए सुरक्षित नहीं' : 'Not safe for infants';
  String get personalisedRisks =>
      isHindi ? 'व्यक्तिगत जोखिम' : 'Personalised risks';
  String get summary => isHindi ? 'सारांश' : 'Summary';
  String get safeToUse => isHindi ? 'उपयोग के लिए सुरक्षित' : 'Safe to use';
  String get avoidThisProduct =>
      isHindi ? 'इस प्रोडक्ट से बचें' : 'Avoid this product';
  String get useWithCaution =>
      isHindi ? 'सावधानी से उपयोग करें' : 'Use with caution';
  String ingredientsCount(int count) =>
      isHindi ? 'सामग्री ($count)' : 'Ingredients ($count)';
  String disguisedIngredientsDetected(int count) => isHindi
      ? '$count छिपी हुई सामग्री मिली'
      : '$count disguised ingredient(s) detected';
  String get labelHonesty => isHindi ? 'लेबल ईमानदारी' : 'Label honesty';
  String claim(Object value) => isHindi ? 'दावा: "$value"' : 'Claim: "$value"';
  String reality(Object value) =>
      isHindi ? 'वास्तविकता: $value' : 'Reality: $value';
  String listedAs(Object value) =>
      isHindi ? 'लेबल पर: $value' : 'Listed as: $value';
  String listedAsTrueIdentity({
    required Object listed,
    required Object trueIdentity,
  }) {
    if (isHindi) return 'लेबल पर "$listed"\nवास्तविक पहचान: $trueIdentity';
    return 'Listed as "$listed"\nTrue identity: $trueIdentity';
  }

  String get chemicalFormula => isHindi ? 'रासायनिक सूत्र' : 'Chemical formula';
  String get formulation => isHindi ? 'फॉर्म्युलेशन' : 'Formulation';
  String get healthImpact => isHindi ? 'स्वास्थ्य प्रभाव' : 'Health impact';
  String get whyItIsUsed =>
      isHindi ? 'इसका उपयोग क्यों होता है' : 'Why it is used';
  String get sustainability => isHindi ? 'स्थिरता' : 'Sustainability';
  String get regulatoryStatus =>
      isHindi ? 'नियामक स्थिति' : 'Regulatory status';
  String get disguised => isHindi ? 'छिपा हुआ' : 'DISGUISED';
  String get allergenUpper => isHindi ? 'एलर्जी' : 'ALLERGEN';
  String get noSaferAlternativesFound =>
      isHindi ? 'कोई सुरक्षित विकल्प नहीं मिला' : 'No safer alternatives found';
  String get betterOptionsForYou =>
      isHindi ? 'आपके लिए बेहतर विकल्प' : 'Better options for you';
  String get allScoredHigher => isHindi
      ? 'इन सभी का स्कोर इस प्रोडक्ट से बेहतर है'
      : 'All scored higher than this product';
  String get globalRegulatoryStatus =>
      isHindi ? 'वैश्विक नियामक स्थिति' : 'Global regulatory status';
  String get noFlaggedIngredients =>
      isHindi ? 'कोई चिन्हित सामग्री नहीं।' : 'No flagged ingredients.';
  String get score => isHindi ? 'स्कोर' : 'Score';
  String get carbon => isHindi ? 'कार्बन' : 'Carbon';
  String get recyclable => isHindi ? 'रीसायकल योग्य' : 'Recyclable';
  String get vegan => isHindi ? 'वीगन' : 'Vegan';
  String get yes => isHindi ? 'हां' : 'Yes';
  String get no => isHindi ? 'नहीं' : 'No';
}
