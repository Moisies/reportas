<?php

use App\Http\Controllers\AccountDeletionController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
})->name('home');

Route::view('/privacidad', 'legal.privacy')->name('legal.privacy');
Route::view('/terminos', 'legal.terms')->name('legal.terms');

Route::prefix('eliminar-cuenta')->name('account.delete.')->group(function () {
    Route::get('/', [AccountDeletionController::class, 'create'])->name('form');
    Route::post('/', [AccountDeletionController::class, 'store'])
        ->middleware('throttle:6,1')
        ->name('submit');
    Route::view('/gracias', 'account.delete-success')->name('success');
});
