<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\TransactionController;

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::prefix('transactions')->group(function () {
    Route::post('/', [TransactionController::class, 'store']); // Create a new transaction
    Route::get('/', [TransactionController::class, 'index']); // Get all transactions
    Route::get('/{id}', [TransactionController::class, 'show']); // Get a specific transaction
    Route::put('/{id}', [TransactionController::class, 'update']); // Update a transaction
    Route::delete('/{id}', [TransactionController::class, 'destroy']); // Delete a transaction
});
