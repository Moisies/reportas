<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class ExchangeRateController extends Controller
{
    use ApiResponse;

    public function show(Request $request): JsonResponse
    {
        $date     = $request->query('date', now()->format('Y-m-d'));
        $currency = strtolower($request->query('currency', 'usd'));

        if ($currency === 'usd') {
            return $this->success(['rate' => 1.0, 'date' => $date, 'currency' => 'USD']);
        }

        $url = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@{$date}/v1/currencies/usd.min.json";

        $response = Http::timeout(10)->get($url);

        if (!$response->successful()) {
            // Fallback: try latest if date not found
            $fallback = Http::timeout(10)->get(
                'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.min.json'
            );

            if (!$fallback->successful()) {
                return $this->error('No se pudo obtener la tasa de cambio', 503);
            }

            $data = $fallback->json();
        } else {
            $data = $response->json();
        }

        $rate = $data['usd'][$currency] ?? null;

        if (is_null($rate)) {
            return $this->error("Moneda '{$currency}' no encontrada", 404);
        }

        return $this->success([
            'rate'     => round($rate, 6),
            'date'     => $data['date'] ?? $date,
            'currency' => strtoupper($currency),
            'base'     => 'USD',
        ]);
    }
}
