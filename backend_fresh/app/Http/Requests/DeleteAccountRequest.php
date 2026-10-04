<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class DeleteAccountRequest extends FormRequest
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
            'reason'       => 'nullable|string|max:1000',
            'confirm'      => 'accepted',
        ];
    }

    public function messages(): array
    {
        return [
            'confirm.accepted' => 'Debes confirmar que entiendes las consecuencias de eliminar tu cuenta.',
        ];
    }
}
