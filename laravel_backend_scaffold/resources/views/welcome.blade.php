<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Libya Medical | Medical SaaS For Clinics & Hospitals</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <style>
        body { font-family: "Plus Jakarta Sans", sans-serif; }
        h1, h2, h3 { font-family: "Space Grotesk", sans-serif; }
    </style>
</head>
<body class="min-h-screen bg-slate-950 text-slate-100 antialiased">
    <div class="absolute inset-0 -z-10 bg-[radial-gradient(circle_at_top_left,_rgba(16,185,129,0.22),_transparent_32%),radial-gradient(circle_at_bottom_right,_rgba(249,115,22,0.18),_transparent_28%),linear-gradient(180deg,_#020617,_#0f172a)]"></div>

    <header class="border-b border-white/10">
        <div class="mx-auto flex max-w-7xl items-center justify-between px-6 py-5 lg:px-8">
            <div>
                <p class="text-sm font-semibold uppercase tracking-[0.35em] text-emerald-300">Libya Medical</p>
            </div>
            <a
                href="{{ url('/login') }}"
                class="inline-flex items-center rounded-full border border-emerald-400/40 bg-emerald-400/10 px-5 py-2.5 text-sm font-semibold text-emerald-200 transition hover:bg-emerald-400/20"
            >
                Login to Dashboard
            </a>
        </div>
    </header>

    <main>
        <section class="mx-auto max-w-7xl px-6 py-20 lg:px-8 lg:py-28">
            <div class="grid gap-16 lg:grid-cols-[1.15fr_0.85fr] lg:items-center">
                <div>
                    <span class="inline-flex rounded-full border border-orange-300/25 bg-orange-300/10 px-4 py-1 text-xs font-semibold uppercase tracking-[0.3em] text-orange-200">
                        B2B2C Healthcare Platform
                    </span>
                    <h1 class="mt-8 max-w-3xl text-5xl font-bold leading-tight text-white md:text-6xl">
                        One SaaS platform for
                        <span class="text-emerald-300">institutions, doctors, and patients.</span>
                    </h1>
                    <p class="mt-6 max-w-2xl text-lg leading-8 text-slate-300">
                        Launch branded clinic operations with doctor onboarding, appointment management,
                        secure access control, and patient-ready mobile experiences from a single Laravel stack.
                    </p>

                    <div class="mt-10 flex flex-col gap-4 sm:flex-row">
                        <a
                            href="{{ url('/login') }}"
                            class="inline-flex items-center justify-center rounded-2xl bg-emerald-400 px-6 py-3.5 text-base font-bold text-slate-950 shadow-lg shadow-emerald-500/30 transition hover:bg-emerald-300"
                        >
                            Login to Dashboard
                        </a>
                        <a
                            href="#pricing"
                            class="inline-flex items-center justify-center rounded-2xl border border-white/15 bg-white/5 px-6 py-3.5 text-base font-semibold text-white transition hover:bg-white/10"
                        >
                            View Pricing
                        </a>
                    </div>

                    <div class="mt-14 grid gap-4 sm:grid-cols-3">
                        <div class="rounded-3xl border border-white/10 bg-white/5 p-5 backdrop-blur">
                            <p class="text-sm font-semibold text-emerald-300">Tenant-Safe</p>
                            <p class="mt-2 text-sm leading-6 text-slate-300">Every institution operates in its own protected data boundary.</p>
                        </div>
                        <div class="rounded-3xl border border-white/10 bg-white/5 p-5 backdrop-blur">
                            <p class="text-sm font-semibold text-emerald-300">Doctor Access</p>
                            <p class="mt-2 text-sm leading-6 text-slate-300">Whitelist-based verification ensures only approved doctors can enter.</p>
                        </div>
                        <div class="rounded-3xl border border-white/10 bg-white/5 p-5 backdrop-blur">
                            <p class="text-sm font-semibold text-emerald-300">Full Stack</p>
                            <p class="mt-2 text-sm leading-6 text-slate-300">Laravel dashboard, APIs, subscriptions, and patient app workflows in one platform.</p>
                        </div>
                    </div>
                </div>

                <div class="relative">
                    <div class="absolute -inset-6 rounded-[2rem] bg-gradient-to-br from-emerald-400/20 via-transparent to-orange-400/20 blur-2xl"></div>
                    <div class="relative overflow-hidden rounded-[2rem] border border-white/10 bg-slate-900/80 p-6 shadow-2xl shadow-slate-950/60 backdrop-blur">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-sm text-slate-400">Operations Snapshot</p>
                                <h2 class="mt-2 text-2xl font-bold text-white">Clinic Command Center</h2>
                            </div>
                            <span class="rounded-full bg-emerald-400/10 px-3 py-1 text-xs font-semibold text-emerald-300">Live</span>
                        </div>

                        <div class="mt-8 space-y-4">
                            <div class="rounded-2xl border border-white/10 bg-slate-950/70 p-4">
                                <div class="flex items-center justify-between text-sm">
                                    <span class="text-slate-400">Active Institutions</span>
                                    <span class="font-semibold text-white">42</span>
                                </div>
                                <div class="mt-3 h-2 rounded-full bg-white/10">
                                    <div class="h-2 w-4/5 rounded-full bg-emerald-400"></div>
                                </div>
                            </div>

                            <div class="grid gap-4 sm:grid-cols-2">
                                <div class="rounded-2xl border border-white/10 bg-white/5 p-4">
                                    <p class="text-sm text-slate-400">Whitelisted Doctors</p>
                                    <p class="mt-2 text-3xl font-bold text-white">1,280</p>
                                    <p class="mt-2 text-sm text-emerald-300">Access controlled by institution</p>
                                </div>
                                <div class="rounded-2xl border border-white/10 bg-white/5 p-4">
                                    <p class="text-sm text-slate-400">Monthly Bookings</p>
                                    <p class="mt-2 text-3xl font-bold text-white">18.4K</p>
                                    <p class="mt-2 text-sm text-orange-300">Queues and schedules managed centrally</p>
                                </div>
                            </div>

                            <div class="rounded-2xl border border-white/10 bg-gradient-to-r from-emerald-400/15 to-orange-400/15 p-5">
                                <p class="text-sm font-semibold text-white">Built for subscription-based growth</p>
                                <p class="mt-2 text-sm leading-6 text-slate-300">
                                    Start with a single clinic and scale to multi-branch hospitals without changing your architecture.
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="mx-auto max-w-7xl px-6 pb-10 lg:px-8">
            <div class="grid gap-6 md:grid-cols-3">
                <div class="rounded-[1.75rem] border border-white/10 bg-white/5 p-8">
                    <p class="text-sm font-semibold uppercase tracking-[0.25em] text-emerald-300">For Institutions</p>
                    <h3 class="mt-4 text-2xl font-bold text-white">Dedicated Dashboards</h3>
                    <p class="mt-4 text-sm leading-7 text-slate-300">Provision each clinic or hospital with its own portal, staff roles, doctor list, and subscription lifecycle.</p>
                </div>
                <div class="rounded-[1.75rem] border border-white/10 bg-white/5 p-8">
                    <p class="text-sm font-semibold uppercase tracking-[0.25em] text-emerald-300">For Doctors</p>
                    <h3 class="mt-4 text-2xl font-bold text-white">Secure Onboarding</h3>
                    <p class="mt-4 text-sm leading-7 text-slate-300">Only doctor phone numbers pre-registered by active institutions are authorized to enter the ecosystem.</p>
                </div>
                <div class="rounded-[1.75rem] border border-white/10 bg-white/5 p-8">
                    <p class="text-sm font-semibold uppercase tracking-[0.25em] text-emerald-300">For Patients</p>
                    <h3 class="mt-4 text-2xl font-bold text-white">Faster Care Access</h3>
                    <p class="mt-4 text-sm leading-7 text-slate-300">Patients book visits, follow queues, and receive coordinated service through a connected medical experience.</p>
                </div>
            </div>
        </section>

        <section id="pricing" class="mx-auto max-w-7xl px-6 py-20 lg:px-8">
            <div class="max-w-2xl">
                <p class="text-sm font-semibold uppercase tracking-[0.3em] text-orange-200">Pricing Plans</p>
                <h2 class="mt-4 text-4xl font-bold text-white">Subscription plans designed for healthcare operators.</h2>
                <p class="mt-4 text-base leading-7 text-slate-300">
                    Start lean, expand when your institution network grows, and keep the same platform across every plan.
                </p>
            </div>

            <div class="mt-12 grid gap-6 lg:grid-cols-3">
                <div class="rounded-[2rem] border border-white/10 bg-white/5 p-8">
                    <p class="text-sm font-semibold uppercase tracking-[0.25em] text-slate-300">Starter</p>
                    <p class="mt-6 text-5xl font-bold text-white">$49<span class="text-lg font-medium text-slate-400">/month</span></p>
                    <ul class="mt-8 space-y-4 text-sm text-slate-300">
                        <li>Single institution dashboard</li>
                        <li>Doctor whitelist management</li>
                        <li>Appointment scheduling basics</li>
                        <li>Email support</li>
                    </ul>
                    <a href="{{ url('/login') }}" class="mt-8 inline-flex rounded-2xl border border-white/15 px-5 py-3 font-semibold text-white transition hover:bg-white/10">
                        Get Started
                    </a>
                </div>

                <div class="rounded-[2rem] border border-emerald-400/40 bg-emerald-400/10 p-8 shadow-xl shadow-emerald-900/30">
                    <div class="flex items-center justify-between">
                        <p class="text-sm font-semibold uppercase tracking-[0.25em] text-emerald-200">Growth</p>
                        <span class="rounded-full bg-white/15 px-3 py-1 text-xs font-semibold text-white">Most Popular</span>
                    </div>
                    <p class="mt-6 text-5xl font-bold text-white">$149<span class="text-lg font-medium text-emerald-100/80">/month</span></p>
                    <ul class="mt-8 space-y-4 text-sm text-emerald-50">
                        <li>Multi-doctor team management</li>
                        <li>Institution admin roles and controls</li>
                        <li>Queue and booking visibility</li>
                        <li>Priority support</li>
                    </ul>
                    <a href="{{ url('/login') }}" class="mt-8 inline-flex rounded-2xl bg-white px-5 py-3 font-semibold text-slate-950 transition hover:bg-emerald-50">
                        Start Growth Plan
                    </a>
                </div>

                <div class="rounded-[2rem] border border-white/10 bg-white/5 p-8">
                    <p class="text-sm font-semibold uppercase tracking-[0.25em] text-orange-200">Enterprise</p>
                    <p class="mt-6 text-5xl font-bold text-white">Custom</p>
                    <ul class="mt-8 space-y-4 text-sm text-slate-300">
                        <li>Multi-branch institution architecture</li>
                        <li>Advanced permission matrices</li>
                        <li>Dedicated onboarding</li>
                        <li>SLA and custom integrations</li>
                    </ul>
                    <a href="{{ url('/login') }}" class="mt-8 inline-flex rounded-2xl border border-orange-300/30 px-5 py-3 font-semibold text-orange-100 transition hover:bg-orange-300/10">
                        Contact Sales
                    </a>
                </div>
            </div>
        </section>
    </main>
</body>
</html>
