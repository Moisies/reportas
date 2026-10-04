<?php

namespace App\Http\Middleware;

use App\Models\UserDevice;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureDeviceRegistered
{
    public function handle(Request $request, Closure $next): Response
    {
        $deviceId = $request->input('device_id') ?? $request->header('X-Device-Id');

        if (!$deviceId) {
            return response()->json(['success' => false, 'message' => 'Device ID requerido'], 403);
        }

        $registered = UserDevice::where('user_id', auth()->id())
            ->where('device_id', $deviceId)
            ->exists();

        if (!$registered) {
            return response()->json(['success' => false, 'message' => 'Dispositivo no registrado'], 403);
        }

        return $next($request);
    }
}
