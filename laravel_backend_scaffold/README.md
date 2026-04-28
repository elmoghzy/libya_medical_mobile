## Laravel Backend Scaffold

This directory contains a Laravel-ready implementation for the requested B2B2C SaaS backend pieces:

- multi-tenancy via `institution_id`
- Spatie roles and permissions
- doctor phone whitelist endpoint
- SaaS marketing landing page

### Notes

- The current workspace does not contain a Laravel application root, so these files are isolated here.
- Copy or merge this structure into your real Laravel backend root.
- This scaffold assumes:
  - Laravel Sanctum is already used for API auth
  - `spatie/laravel-permission` is installed and published
  - your main business tables are `users`, `doctors`, `patients`, and `bookings`

### Integration Steps

1. Install Spatie if not already installed:

```bash
composer require spatie/laravel-permission
php artisan vendor:publish --provider="Spatie\Permission\PermissionServiceProvider"
php artisan migrate
```

2. Copy the files into your Laravel project.

3. Run:

```bash
php artisan migrate
php artisan db:seed --class=RolesAndPermissionsSeeder
```

4. Register the API route:

```text
POST /api/auth/check-doctor-phone
```

5. Use the `BelongsToInstitution` trait on any model that must be tenant-scoped.
