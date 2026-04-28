<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\CheckDoctorPhoneRequest;
use App\Http\Resources\Api\WhitelistStatusResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

class AuthController extends Controller
{
    public function checkDoctorPhone(CheckDoctorPhoneRequest $request): JsonResponse
    {
        $phone = $request->validated()['phone'];

        $doctor = User::query()
            ->where('phone', $phone)
            ->whereNotNull('institution_id')
            ->role('Doctor')
            ->whereHas('institution', function ($query): void {
                $query->where('is_active', true);
            })
            ->first();

        if (! $doctor) {
            return (new WhitelistStatusResource([
                'success' => false,
                'message' => 'Phone not registered by any active institution',
            ]))
                ->response()
                ->setStatusCode(Response::HTTP_FORBIDDEN);
        }

        return (new WhitelistStatusResource([
            'success' => true,
            'message' => 'Authorized',
        ]))
            ->response()
            ->setStatusCode(Response::HTTP_OK);
    }
}
