<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CompanyController;
use App\Http\Controllers\Api\ExchangeRateController;
use App\Http\Controllers\Api\ExpenseController;
use App\Http\Controllers\Api\ExpenseTypeController;
use App\Http\Controllers\Api\ProjectController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {

    Route::prefix('auth')->group(function () {
        Route::post('login',     [AuthController::class, 'login']);
        Route::post('biometric', [AuthController::class, 'biometric']);
    });

    Route::middleware('auth:sanctum')->group(function () {

        Route::prefix('auth')->group(function () {
            Route::post('logout', [AuthController::class, 'logout']);
            Route::get('me',      [AuthController::class, 'me']);
        });

        Route::get('projects',               [ProjectController::class, 'index']);
        Route::get('projects/{id}/currency', [ProjectController::class, 'currency']);
        Route::get('companies',     [CompanyController::class, 'index']);
        Route::get('expense-types', [ExpenseTypeController::class, 'index']);

        Route::get('exchange-rate', [ExchangeRateController::class, 'show']);

        Route::get('expenses',  [ExpenseController::class, 'index']);
        Route::post('expenses', [ExpenseController::class, 'store'])
            ->middleware('device.registered');

        Route::get('expenses/mine', [ExpenseController::class, 'myReceipts']);
        Route::get('expenses/{id}/receipt-image', [ExpenseController::class, 'receiptImage'])
            ->name('api.expenses.receipt-image');
        Route::delete('expenses/{id}', [ExpenseController::class, 'destroy']);
    });
});
