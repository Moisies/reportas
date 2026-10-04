<?php

namespace App\Traits;

use Illuminate\Http\JsonResponse;

trait ApiResponse
{
    protected function success($data = null, string $message = 'OK', int $code = 200): JsonResponse
    {
        $response = ['success' => true, 'message' => $message];
        if (!is_null($data)) {
            $response['data'] = $data;
        }
        return response()->json($response, $code);
    }

    protected function created($data = null, string $message = 'Creado exitosamente'): JsonResponse
    {
        return $this->success($data, $message, 201);
    }

    protected function error(string $message = 'Error', int $code = 400, $errors = null): JsonResponse
    {
        $response = ['success' => false, 'message' => $message];
        if (!is_null($errors)) {
            $response['errors'] = $errors;
        }
        return response()->json($response, $code);
    }

    protected function notFound(string $message = 'No encontrado'): JsonResponse
    {
        return $this->error($message, 404);
    }

    protected function unauthorized(string $message = 'No autorizado'): JsonResponse
    {
        return $this->error($message, 401);
    }
}
