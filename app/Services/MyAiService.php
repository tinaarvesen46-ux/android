<?php

namespace App\Services;

use App\Models\AiAgent;
use Illuminate\Support\Facades\Http;
use RuntimeException;

/**
 * Provider boundary for My AI. The mobile client never receives provider
 * credentials and never talks to an LLM directly.
 */
class MyAiService
{
    public function reply(string $prompt, ?AiAgent $agent = null): string
    {
        $provider = strtolower((string) ($agent?->provider ?: env('AI_PROVIDER', 'none')));
        $baseUrl = rtrim((string) ($agent?->base_url ?: env('AI_BASE_URL', '')), '/');
        $model = (string) ($agent?->model ?: env('AI_MODEL', ''));

        if ($provider === 'none' || $baseUrl === '' || $model === '') {
            throw new RuntimeException('My AI is not enabled on this server.');
        }

        $response = Http::timeout(25)->acceptJson()->post($baseUrl . '/v1/chat/completions', [
            'model' => $model,
            'messages' => [
                ['role' => 'system', 'content' => 'You are My AI, a safe and concise SwiftSnap assistant. Do not claim to perform actions you cannot perform.'],
                ['role' => 'user', 'content' => $prompt],
            ],
            'temperature' => 0.7,
            'max_tokens' => 512,
        ]);

        if ($response->failed()) {
            throw new RuntimeException('The configured My AI provider is unavailable.');
        }

        $text = trim((string) data_get($response->json(), 'choices.0.message.content', ''));
        if ($text === '') {
            throw new RuntimeException('My AI returned an empty response.');
        }

        return $text;
    }
}
