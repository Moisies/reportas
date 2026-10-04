<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class CompanyController extends Controller
{
    use ApiResponse;

    public function index(): JsonResponse
    {
        $companies = DB::select(
            'EXEC dbo.app_RegentCompany @iCurrentUserId = ?',
            [auth()->id()]
        );

        return $this->success($companies);
    }
}
