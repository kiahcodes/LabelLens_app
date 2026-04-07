def apply_personalization(
    gemini_result: dict, user_profile: dict
) -> dict:
    """
    Re-scores ingredients based on user profile.
    Only makes things MORE strict — never downgrades a RED.
    """
    allergies = [
        a.lower() for a in user_profile.get('allergies', [])
    ]
    is_pregnant = user_profile.get('is_pregnant', False)
    baby_mode = user_profile.get('baby_mode', False)

    red_count = 0
    yellow_count = 0
    personalized_risks = []
    allergen_alerts = list(
        gemini_result.get('allergen_alerts', [])
    )

    for ingredient in gemini_result.get('ingredients', []):
        # --- Pregnancy override ---
        if is_pregnant and ingredient.get('pregnancy_risk'):
            ingredient['safety_label'] = 'RED'
            name = ingredient.get('canonical_name', '')
            personalized_risks.append(
                f"{name} is not recommended during pregnancy."
            )

        # --- Baby mode override ---
        if baby_mode and ingredient.get('baby_risk'):
            ingredient['safety_label'] = 'RED'
            name = ingredient.get('canonical_name', '')
            personalized_risks.append(
                f"{name} may not be safe for infants."
            )

        # --- Allergen override ---
        allergen_type = (
            ingredient.get('allergen_type') or ''
        ).lower()
        if ingredient.get('allergen') and allergies:
            matched = any(
                a in allergen_type or allergen_type in a
                for a in allergies
            )
            if matched:
                ingredient['safety_label'] = 'RED'
                allergen_alerts.append({
                    'allergen': ingredient.get(
                        'allergen_type', ''),
                    'found_in': ingredient.get(
                        'canonical_name', ''),
                    'severity': 'HIGH',
                })
                personalized_risks.append(
                    f"ALLERGEN: {ingredient.get('allergen_type')}"
                    f" detected in "
                    f"{ingredient.get('canonical_name')}."
                )

        # Count final labels
        label = ingredient.get('safety_label', 'GREEN')
        if label == 'RED':
            red_count += 1
        elif label == 'YELLOW':
            yellow_count += 1

    # Recalculate overall score
    total = len(gemini_result.get('ingredients', []))
    if total > 0:
        new_score = max(
            0,
            100 - (red_count * 25) - (yellow_count * 10)
        )
        gemini_result['overall_safety_score'] = new_score

    # Strict rule: any RED ingredient makes overall RED
    if red_count > 0:
        gemini_result['verdict'] = 'RED'
    else:
        score = gemini_result.get('overall_safety_score', 50)
        if score >= 70:
            gemini_result['verdict'] = 'GREEN'
        elif score >= 40:
            gemini_result['verdict'] = 'YELLOW'
        else:
            gemini_result['verdict'] = 'RED'

    # Merge personalized risks (no duplicates)
    existing = set(gemini_result.get('personalized_risks', []))
    gemini_result['personalized_risks'] = list(existing) + [
        r for r in personalized_risks if r not in existing
    ]
    gemini_result['allergen_alerts'] = allergen_alerts

    # Remove assessments if modes are OFF
    if not is_pregnant:
        gemini_result.pop('pregnancy_assessment', None)
    if not baby_mode:
        gemini_result.pop('baby_assessment', None)

    return gemini_result