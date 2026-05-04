<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\Post;
use App\Models\PostLike;
use App\Models\Comment;
use App\Models\Notification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PostControllerTest extends TestCase
{
    use RefreshDatabase;

    /**
     * 1. test_user_can_create_post
     */
    public function test_user_can_create_post()
    {
        $user = $this->createAuthenticatedUser();

        $response = $this->withoutMiddleware()->postJson('/api/posts', [
            'content' => 'Test post content',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Post berhasil dibuat.',
            ]);

        $this->assertDatabaseHas('posts', [
            'user_id' => $user->id,
            'content' => 'Test post content',
        ]);
    }

    /**
     * 2. test_post_creation_validates_content_required
     */
    public function test_post_creation_validates_content_required()
    {
        $this->createAuthenticatedUser();

        $response = $this->withoutMiddleware()->postJson('/api/posts', [
            'content' => '',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['content']);
    }

    /**
     * 3. test_user_can_delete_own_post
     */
    public function test_user_can_delete_own_post()
    {
        $user = $this->createAuthenticatedUser();
        $post = Post::create([
            'user_id' => $user->id,
            'content' => 'Post to be deleted',
        ]);

        $response = $this->withoutMiddleware()->deleteJson("/api/posts/{$post->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Post berhasil dihapus.',
            ]);

        $this->assertDatabaseMissing('posts', ['id' => $post->id]);
    }

    /**
     * 4. test_user_cannot_delete_others_post
     */
    public function test_user_cannot_delete_others_post()
    {
        $owner = User::factory()->create(['supabase_id' => 'owner-id']);
        $post = Post::create([
            'user_id' => $owner->id,
            'content' => 'Others post',
        ]);

        $this->createAuthenticatedUser();

        $response = $this->withoutMiddleware()->deleteJson("/api/posts/{$post->id}");

        $response->assertStatus(404)
            ->assertJson([
                'success' => false,
                'message' => 'Post tidak ditemukan atau bukan milik Anda.',
            ]);

        $this->assertDatabaseHas('posts', ['id' => $post->id]);
    }

    /**
     * 5. test_toggle_like_creates_like
     */
    public function test_toggle_like_creates_like()
    {
        $user = $this->createAuthenticatedUser();
        $owner = User::factory()->create(['supabase_id' => 'owner-id-2']);
        $post = Post::create([
            'user_id' => $owner->id,
            'content' => 'Test post for like',
        ]);

        $response = $this->withoutMiddleware()->postJson("/api/posts/{$post->id}/like");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'liked' => true,
                'likes_count' => 1,
            ]);

        $this->assertDatabaseHas('post_likes', [
            'user_id' => $user->id,
            'post_id' => $post->id,
        ]);
    }

    /**
     * 6. test_toggle_like_removes_like
     */
    public function test_toggle_like_removes_like()
    {
        $user = $this->createAuthenticatedUser();
        $post = Post::create([
            'user_id' => $user->id,
            'content' => 'Test post for unlike',
        ]);

        PostLike::create([
            'user_id' => $user->id,
            'post_id' => $post->id,
        ]);

        $response = $this->withoutMiddleware()->postJson("/api/posts/{$post->id}/like");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'liked' => false,
                'likes_count' => 0,
            ]);

        $this->assertDatabaseMissing('post_likes', [
            'user_id' => $user->id,
            'post_id' => $post->id,
        ]);
    }

    /**
     * 7. test_like_creates_notification_for_post_owner
     */
    public function test_like_creates_notification_for_post_owner()
    {
        $user = $this->createAuthenticatedUser();
        $owner = User::factory()->create(['supabase_id' => 'owner-id-3', 'name' => 'Owner Name']);
        $post = Post::create([
            'user_id' => $owner->id,
            'content' => 'Post to notify',
        ]);

        $this->withoutMiddleware()->postJson("/api/posts/{$post->id}/like");

        $this->assertDatabaseHas('notifications', [
            'user_id' => $owner->id,
            'actor_id' => $user->id,
            'type' => 'like',
            'post_id' => $post->id,
        ]);
    }

    /**
     * 8. test_user_can_add_comment
     */
    public function test_user_can_add_comment()
    {
        $user = $this->createAuthenticatedUser();
        $post = Post::create([
            'user_id' => $user->id,
            'content' => 'Post for comment',
        ]);

        $response = $this->withoutMiddleware()->postJson("/api/posts/{$post->id}/comments", [
            'content' => 'Test comment',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Komentar berhasil ditambahkan.',
            ]);

        $this->assertDatabaseHas('comments', [
            'user_id' => $user->id,
            'post_id' => $post->id,
            'content' => 'Test comment',
            'parent_id' => null,
        ]);
    }

    /**
     * 9. test_comment_validates_content_required
     */
    public function test_comment_validates_content_required()
    {
        $user = $this->createAuthenticatedUser();
        $post = Post::create([
            'user_id' => $user->id,
            'content' => 'Post for invalid comment',
        ]);

        $response = $this->withoutMiddleware()->postJson("/api/posts/{$post->id}/comments", [
            'content' => '',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['content']);
    }

    /**
     * 10. test_reply_to_comment_sets_parent_id
     */
    public function test_reply_to_comment_sets_parent_id()
    {
        $user = $this->createAuthenticatedUser();
        $post = Post::create([
            'user_id' => $user->id,
            'content' => 'Post for reply',
        ]);

        $comment = Comment::create([
            'user_id' => $user->id,
            'post_id' => $post->id,
            'content' => 'Parent comment',
        ]);

        $response = $this->withoutMiddleware()->postJson("/api/posts/{$post->id}/comments", [
            'content' => 'Reply comment',
            'parent_id' => $comment->id,
        ]);

        $response->assertStatus(201);

        $this->assertDatabaseHas('comments', [
            'user_id' => $user->id,
            'post_id' => $post->id,
            'content' => 'Reply comment',
            'parent_id' => $comment->id,
        ]);
    }

    /**
     * 11. test_nested_reply_flattens_to_top_level_parent
     */
    public function test_nested_reply_flattens_to_top_level_parent()
    {
        $user = $this->createAuthenticatedUser();
        $post = Post::create([
            'user_id' => $user->id,
            'content' => 'Post for nested reply',
        ]);

        $topLevel = Comment::create([
            'user_id' => $user->id,
            'post_id' => $post->id,
            'content' => 'Top level comment',
        ]);

        $secondLevel = Comment::create([
            'user_id' => $user->id,
            'post_id' => $post->id,
            'parent_id' => $topLevel->id,
            'content' => 'Second level comment',
        ]);

        $response = $this->withoutMiddleware()->postJson("/api/posts/{$post->id}/comments", [
            'content' => 'Third level comment',
            'parent_id' => $secondLevel->id,
        ]);

        $response->assertStatus(201);

        // Controller should flatten this to the top level parent
        $this->assertDatabaseHas('comments', [
            'content' => 'Third level comment',
            'parent_id' => $topLevel->id,
        ]);
    }

    /**
     * 12. test_user_can_toggle_pin_post
     */
    public function test_user_can_toggle_pin_post()
    {
        $user = $this->createAuthenticatedUser();
        $post = Post::create([
            'user_id' => $user->id,
            'content' => 'Post to pin',
            'is_pinned' => false,
        ]);

        $response = $this->withoutMiddleware()->postJson("/api/posts/{$post->id}/pin");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'is_pinned' => true,
            ]);

        $this->assertTrue($post->fresh()->is_pinned);
    }

    /**
     * 13. test_max_three_pinned_posts
     */
    public function test_max_three_pinned_posts()
    {
        $user = $this->createAuthenticatedUser();
        
        // Create and pin 3 posts
        $post1 = Post::create(['user_id' => $user->id, 'content' => 'Post 1', 'is_pinned' => true, 'pinned_at' => now()->subMinutes(10)]);
        $post2 = Post::create(['user_id' => $user->id, 'content' => 'Post 2', 'is_pinned' => true, 'pinned_at' => now()->subMinutes(5)]);
        $post3 = Post::create(['user_id' => $user->id, 'content' => 'Post 3', 'is_pinned' => true, 'pinned_at' => now()]);

        // Create 4th post and pin it
        $post4 = Post::create(['user_id' => $user->id, 'content' => 'Post 4', 'is_pinned' => false]);

        $response = $this->withoutMiddleware()->postJson("/api/posts/{$post4->id}/pin");

        $response->assertStatus(200);

        // Post 4 should be pinned
        $this->assertTrue($post4->fresh()->is_pinned);

        // Post 1 (oldest pin) should be unpinned
        $this->assertFalse($post1->fresh()->is_pinned);
        
        // Post 2 and 3 should still be pinned
        $this->assertTrue($post2->fresh()->is_pinned);
        $this->assertTrue($post3->fresh()->is_pinned);
        
        // Total pinned should be 3
        $this->assertEquals(3, Post::where('user_id', $user->id)->where('is_pinned', true)->count());
    }
}
