<?php

namespace App\Http\Requests\Api;

use Illuminate\Foundation\Http\FormRequest;

class CheckDoctorPhoneRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    protected function prepareForValidation(): void
    {
        $phone = preg_replace('/[^\d+]/', '', (string) $this->input('phone'));

        $this->merge([
            'phone' => $phone,
        ]);
    }

    public function rules(): array
    {
        return [
            'phone' => ['required', 'string', 'regex:/^\+?\d{8,15}$/'],
        ];
    }

    public function messages(): array
    {
        return [
            'phone.regex' => 'The phone field must be a valid international phone number.',
        ];
    }
}
