def apply_personalization(gemini_result: dict, user_profile: dict) -> dict:
    """
    Re-score ingredients and update overall verdict based on user profile.
    Modifies the dict in-place and returns it.
    """
    allergies = [a.lower() for a in user_profile.get("allergies", [])]
    is_pregnant = user_profile.get("is_pregnant", False)
    baby_mode = user_profile.get("baby_mode", False)
    dietary = [d.lower() for d in user_profile.get("dietary_restrictions", [])]

    red_count = 0
    yellow_count = 0
    personalized_risks = []
    allergen_alerts = gemini_result.get("allergen_alerts", [])

    for ingredient in gemini_result.get("ingredients", []):
        forced_red = False

        # Pregnancy override
        if is_pregnant and ingredient.get("pregnancy_risk"):
            ingredient["safety_label"] = "RED"
            forced_red = True
            personalized_risks.append(
                f"{ingredient['canonical_name']} is not recommended during pregnancy."
            )

        # Baby mode override
        if baby_mode and ingredient.get("baby_risk"):
            ingredient["safety_label"] = "RED"
            forced_red = True
            personalized_risks.append(
                f"{ingredient['canonical_name']} may not be safe for infants."
            )

        # Allergen override
        allergen_type = (ingredient.get("allergen_type") or "").lower()
        if ingredient.get("allergen") and any(
            a in allergen_type or allergen_type in a for a in allergies
        ):
            ingredient["safety_label"] = "RED"
            forced_red = True
            allergen_alerts.append({
                "allergen": ingredient["allergen_type"],
                "found_in": ingredient["canonical_name"],
                "severity": "HIGH",
            })
            personalized_risks.append(
                f"⚠️ ALLERGEN ALERT: {ingredient['allergen_type']} detected in {ingredient['canonical_name']}."
            )

        # Dietary restriction checks
        if "vegan" in dietary and ingredient.get("allergen_type", "").lower() in [
            "milk", "eggs", "honey", "gelatin"
        ]:
            personalized_risks.append(
                f"{ingredient['canonical_name']} is not vegan (contains {ingredient['allergen_type']})."
            )

        label = ingredient["safety_label"]
        if label == "RED":
            red_count += 1
        elif label == "YELLOW":
            yellow_count += 1

    # Recalculate overall score
    total_ingredients = len(gemini_result.get("ingredients", []))
    if total_ingredients > 0:
        new_score = max(
            0, 100 - (red_count * 25) - (yellow_count * 10)
        )
        gemini_result["overall_safety_score"] = new_score
    
    # Update verdict
    score = gemini_result["overall_safety_score"]
    if score >= 70:
        gemini_result["verdict"] = "GREEN"
    elif score >= 40:
        gemini_result["verdict"] = "YELLOW"
    else:
        gemini_result["verdict"] = "RED"

    # Add personalized risks (deduplicate)
    existing = set(gemini_result.get("personalized_risks", []))
    gemini_result["personalized_risks"] = list(existing) + [
        r for r in personalized_risks if r not in existing
    ]
    gemini_result["allergen_alerts"] = allergen_alerts

    # Remove assessments if not applicable
    if not is_pregnant:
        gemini_result.pop("pregnancy_assessment", None)
    if not baby_mode:
        gemini_result.pop("baby_assessment", None)

    return gemini_result