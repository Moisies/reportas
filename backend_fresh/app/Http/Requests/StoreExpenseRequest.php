<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreExpenseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'project_id'      => 'required|integer',
            'expense_type_id' => 'required|integer',
            'amount'          => 'required|numeric|min:0.01|max:999999.99',
            'exchange_rate'   => 'nullable|numeric|min:0.0001',
            'expense_date'    => 'required|date|before_or_equal:today',
            'description'     => 'nullable|string|max:255',
            'device_id'       => 'required|string',
            'receipt_image'   => 'required|image|mimes:jpeg,png,jpg|max:10240',
        ];
    }

    public function messages(): array
    {
        return [
            'project_id.required'      => 'El proyecto es requerido',
            'expense_type_id.required' => 'El tipo de gasto es requerido',
            'amount.required'          => 'El monto es requerido',
            'amount.min'               => 'El monto debe ser mayor a 0',
            'expense_date.required'    => 'La fecha es requerida',
            'expense_date.before_or_equal' => 'La fecha no puede ser futura',
            'receipt_image.required'   => 'La imagen del recibo es requerida',
            'receipt_image.max'        => 'La imagen no puede superar 10MB',
            'receipt_image.mimes'      => 'La imagen debe ser JPEG o PNG',
        ];
    }
}
