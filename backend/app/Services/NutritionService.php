<?php

namespace App\Services;

class NutritionService
{
    /**
     * Calculate BMI.
     */
    public function calculateBmi(float $weight, float $height): float
    {
        if ($height <= 0) {
            return 0.0;
        }
        $heightInMeter = $height / 100;
        return $weight / ($heightInMeter * $heightInMeter);
    }

    /**
     * Determine BMI status (WHO Classification).
     */
    public function getBmiStatus(float $bmi): string
    {
        if ($bmi < 16.0) return 'Severely Underweight';
        if ($bmi < 18.5) return 'Underweight';
        if ($bmi < 25.0) return 'Normal';
        if ($bmi < 30.0) return 'Overweight';
        if ($bmi < 35.0) return 'Obesity Class I';
        if ($bmi < 40.0) return 'Obesity Class II';
        return 'Obesity Class III';
    }

    /**
     * Calculate BMR (Mifflin-St Jeor).
     */
    public function calculateBmr(float $weight, float $height, int $age, string $gender): float
    {
        if ($gender === 'male') {
            return (10 * $weight) + (6.25 * $height) - (5 * $age) + 5;
        } else {
            return (10 * $weight) + (6.25 * $height) - (5 * $age) - 161;
        }
    }

    /**
     * Calculate TDEE based on BMR and activity level.
     */
    public function calculateTdee(float $bmr, string $activityLevel): float
    {
        $factors = [
            'sedentary' => 1.2,
            'light' => 1.375,
            'moderate' => 1.55,
            'active' => 1.725,
            'very_active' => 1.9
        ];

        return $bmr * ($factors[$activityLevel] ?? 1.2);
    }

    /**
     * Adjust target calories based on goal.
     */
    public function calculateTargetCalories(float $tdee, string $goal): float
    {
        $targetCalories = $tdee;
        if ($goal === 'cutting') $targetCalories -= 500;
        if ($goal === 'bulking') $targetCalories += 500;
        return $targetCalories;
    }

    /**
     * Calculate macronutrient recommendations.
     */
    public function calculateMacros(float $calories, float $weightKg, string $goal): array
    {
        if ($calories <= 0) {
            return [
                'protein' => ['grams' => 0, 'percent' => 0],
                'carbohydrates' => ['grams' => 0, 'percent' => 0],
                'fat' => ['grams' => 0, 'percent' => 0],
            ];
        }

        // Rasio makronutrien berdasarkan goal (evidence-based)
        $proteinRatio = match ($goal) {
            'cutting' => 0.35,
            'bulking' => 0.28,
            default => 0.28,
        };
        $carbRatio = match ($goal) {
            'cutting' => 0.38,
            'bulking' => 0.48,
            default => 0.45,
        };
        $fatRatio = 1.0 - $proteinRatio - $carbRatio;

        $proteinG = ($calories * $proteinRatio) / 4;
        $carbsG = ($calories * $carbRatio) / 4;

        // Minimum protein berdasarkan berat badan dan goal
        $minProtein = match ($goal) {
            'cutting' => $weightKg * 1.8,  // 1.6-2.2 g/kg for cutting
            'bulking' => $weightKg * 1.6,  // 1.4-2.0 g/kg for bulking
            default => $weightKg * 1.0,    // 0.8-1.2 g/kg RDA
        };

        $finalProteinG = max($proteinG, $minProtein);

        // Recalculate fat with remaining calories
        $remainingCal = $calories - ($finalProteinG * 4) - ($carbsG * 4);
        $finalFatG = max($remainingCal / 9, ($calories * 0.15) / 9);

        return [
            'protein' => [
                'grams' => round($finalProteinG),
                'percent' => round(($finalProteinG * 4 / $calories) * 100),
            ],
            'carbohydrates' => [
                'grams' => round($carbsG),
                'percent' => round(($carbsG * 4 / $calories) * 100),
            ],
            'fat' => [
                'grams' => round($finalFatG),
                'percent' => round(($finalFatG * 9 / $calories) * 100),
            ],
        ];
    }
}
