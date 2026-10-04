<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'login_name'   => 'required|string',
            'password'     => 'required|string',
            'phone_number' => 'required|string',
            'device_id'    => 'required|string',
            'device_name'  => 'nullable|string|max:255',
        ];
    }
}
