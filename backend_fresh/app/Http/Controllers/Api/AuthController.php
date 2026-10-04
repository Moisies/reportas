<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\BiometricLoginRequest;
use App\Http\Requests\LoginRequest;
use App\Services\AuthService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    use ApiResponse;

    public function __construct(private AuthService $authService) {}

    public function login(LoginRequest $request): JsonResponse
    {
        $user = $this->authService->login(
            $request->login_name,
            $request->password,
            $request->phone_number
        );

        if (!$user) {
            return $this->unauthorized('Credenciales inválidas');
        }

        $device = $this->authService->registerDevice(
            $user->UserId,
            $request->device_id,
            $request->device_name ?? 'Mobile App'
        );

        $token = $user->createToken($request->device_name ?? 'api-token')->plainTextToken;

        return $this->success([
            'token'           => $token,
            'biometric_token' => $device->biometric_token_plain,
            'user'            => [
                'id'    => $user->UserId,
                'name'  => $user->UserName,
                'email' => $user->EmailAddress,
            ],
        ]);
    }

    public function biometric(BiometricLoginRequest $request): JsonResponse
    {
        $user = $this->authService->loginBiometric(
            $request->device_id,
            $request->biometric_token
        );

        if (!$user) {
            return $this->unauthorized('Dispositivo no registrado o token inválido');
        }

        $token = $user->createToken('biometric-token')->plainTextToken;

        return $this->success([
            'token' => $token,
            'user'  => [
                'id'    => $user->UserId,
                'name'  => $user->UserName,
                'email' => $user->EmailAddress,
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();
        return $this->success(null, 'Sesión cerrada');
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        return $this->success([
            'id'    => $user->UserId,
            'name'  => $user->UserName,
            'email' => $user->EmailAddress,
        ]);
    }
}
