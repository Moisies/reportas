<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class BiometricLoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'device_id'       => 'required|string',
            'biometric_token' => 'required|string',
        ];
    }
}
