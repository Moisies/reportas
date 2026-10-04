<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ExpenseType;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;

class ExpenseTypeController extends Controller
{
    use ApiResponse;

    public function index(): JsonResponse
    {
        $types = ExpenseType::whereNull('DeleteDate')
            ->orderBy('ExpenseTypeId')
            ->get(['ExpenseTypeId', 'ExpenseTypeName', 'DisplayName']);

        return $this->success($types);
    }
}
