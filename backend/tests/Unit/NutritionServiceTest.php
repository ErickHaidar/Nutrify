<?php

namespace Tests\Unit;

use App\Services\NutritionService;
use PHPUnit\Framework\TestCase;

class NutritionServiceTest extends TestCase
{
    private NutritionService $service;

    protected function setUp(): void
    {
        parent::setUp();
        $this->service = new NutritionService();
    }

    public function test_calculate_bmi()
    {
        $weight = 70;
        $height = 175;
        $bmi = $this->service->calculateBmi($weight, $height);
        $this->assertEquals(22.86, round($bmi, 2));
    }

    public function test_get_bmi_status()
    {
        $this->assertEquals('Normal', $this->service->getBmiStatus(22.86));
        $this->assertEquals('Underweight', $this->service->getBmiStatus(17.5));
        $this->assertEquals('Overweight', $this->service->getBmiStatus(27.0));
    }

    public function test_calculate_bmr_male()
    {
        $bmr = $this->service->calculateBmr(70, 175, 25, 'male');
        // (10 * 70) + (6.25 * 175) - (5 * 25) + 5 = 700 + 1093.75 - 125 + 5 = 1673.75
        $this->assertEquals(1673.75, $bmr);
    }

    public function test_calculate_bmr_female()
    {
        $bmr = $this->service->calculateBmr(60, 165, 30, 'female');
        // (10 * 60) + (6.25 * 165) - (5 * 30) - 161 = 600 + 1031.25 - 150 - 161 = 1320.25
        $this->assertEquals(1320.25, $bmr);
    }

    public function test_calculate_tdee()
    {
        $bmr = 1673.75;
        $tdee = $this->service->calculateTdee($bmr, 'moderate');
        $this->assertEquals(1673.75 * 1.55, $tdee);
    }

    public function test_calculate_target_calories()
    {
        $tdee = 2500;
        $this->assertEquals(2000, $this->service->calculateTargetCalories($tdee, 'cutting'));
        $this->assertEquals(3000, $this->service->calculateTargetCalories($tdee, 'bulking'));
        $this->assertEquals(2500, $this->service->calculateTargetCalories($tdee, 'maintenance'));
    }

    public function test_calculate_macros()
    {
        $calories = 2000;
        $weight = 70;
        $goal = 'cutting';
        
        $macros = $this->service->calculateMacros($calories, $weight, $goal);
        
        $this->assertArrayHasKey('protein', $macros);
        $this->assertArrayHasKey('carbohydrates', $macros);
        $this->assertArrayHasKey('fat', $macros);
        
        // Basic check for cutting goal (higher protein)
        $this->assertGreaterThan(0, $macros['protein']['grams']);
    }
}
