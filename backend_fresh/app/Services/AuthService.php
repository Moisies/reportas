<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserDevice;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class AuthService
{
    public function login(string $loginName, string $password, string $phoneNumber): ?User
    {
        $result = DB::select(
            'EXEC dbo.app_AuthenticateUser @sLoginName = ?, @sPassword = ?, @sPhoneNumber = ?',
            [$loginName, $password, $phoneNumber]
        );

        // SP returns column 'UserId' on success, '' (empty name) with NULL on failure
        $row    = (array) ($result[0] ?? []);
        $userId = array_values($row)[0] ?? null;

        if (is_null($userId)) {
            return null;
        }

        return User::find($userId);
    }

    public function loginBiometric(string $deviceId, string $biometricToken): ?User
    {
        $device = UserDevice::where('device_id', $deviceId)
            ->where('biometric_token', $biometricToken)
            ->first();

        if (!$device) {
            return null;
        }

        $device->last_used_at = now();
        $device->save();

        return User::find($device->user_id);
    }

    public function registerDevice(int $userId, string $deviceId, string $deviceName): UserDevice
    {
        $biometricToken = Str::random(64);

        $device = UserDevice::updateOrCreate(
            ['user_id' => $userId, 'device_id' => $deviceId],
            [
                'device_name'     => $deviceName,
                'biometric_token' => $biometricToken,
                'last_used_at'    => now(),
            ]
        );

        $device->biometric_token_plain = $biometricToken;

        return $device;
    }
}
