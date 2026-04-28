<?php

namespace App\Models\Concerns;

use App\Models\Institution;
use App\Models\Scopes\TenantScope;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Auth;

trait BelongsToInstitution
{
    public static function bootBelongsToInstitution(): void
    {
        static::addGlobalScope(new TenantScope);

        static::creating(function (Model $model): void {
            $user = Auth::user();

            if (! $user || $user->isSuperAdmin()) {
                return;
            }

            if (blank($model->institution_id)) {
                $model->institution_id = $user->institution_id;
            }
        });
    }

    public function institution(): BelongsTo
    {
        return $this->belongsTo(Institution::class);
    }
}
