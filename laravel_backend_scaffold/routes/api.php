<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function (): void {
    Route::post('/check-doctor-phone', [AuthController::class, 'checkDoctorPhone'])
        ->name('api.auth.check-doctor-phone');
});
