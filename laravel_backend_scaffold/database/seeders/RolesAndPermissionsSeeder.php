<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class RolesAndPermissionsSeeder extends Seeder
{
    public function run(): void
    {
        app(PermissionRegistrar::class)->forgetCachedPermissions();

        $guard = config('auth.defaults.guard', 'web');

        $permissions = [
            'manage_institutions',
            'manage_doctors',
            'view_appointments',
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate([
                'name' => $permission,
                'guard_name' => $guard,
            ]);
        }

        $superAdmin = Role::firstOrCreate([
            'name' => 'SuperAdmin',
            'guard_name' => $guard,
        ]);

        $institutionAdmin = Role::firstOrCreate([
            'name' => 'InstitutionAdmin',
            'guard_name' => $guard,
        ]);

        $doctor = Role::firstOrCreate([
            'name' => 'Doctor',
            'guard_name' => $guard,
        ]);

        $superAdmin->syncPermissions($permissions);
        $institutionAdmin->syncPermissions([
            'manage_doctors',
            'view_appointments',
        ]);
        $doctor->syncPermissions([
            'view_appointments',
        ]);
    }
}
