<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class DatabaseSchemaTest extends TestCase
{
    use RefreshDatabase;

    /**
     * Test that the foods table has an index on the name column.
     *
     * @return void
     */
    public function test_foods_table_has_name_index()
    {
        $this->assertTrue(
            Schema::hasIndex('foods', 'foods_name_index'),
            'The foods table does not have an index on the name column.'
        );
    }
}
