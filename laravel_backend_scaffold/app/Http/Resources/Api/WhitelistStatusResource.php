<?php

namespace App\Http\Resources\Api;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WhitelistStatusResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'success' => (bool) data_get($this->resource, 'success'),
            'message' => (string) data_get($this->resource, 'message'),
        ];
    }
}
