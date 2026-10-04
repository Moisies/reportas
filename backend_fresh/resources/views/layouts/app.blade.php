<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', config('legal.app_name') . ' — ' . config('legal.company_name'))</title>
    <meta name="description" content="@yield('description', 'Registro de gastos y recibos en campo para agentes de ' . config('legal.company_name') . '.')">
    <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Crect width='100' height='100' rx='22' fill='%232563eb'/%3E%3Ctext x='50' y='68' font-size='58' font-family='Arial,sans-serif' font-weight='700' fill='white' text-anchor='middle'%3ER%3C/text%3E%3C/svg%3E">
    <style>
        :root {
            --bg: #f8fafc;
            --surface: #ffffff;
            --surface-alt: #f1f5f9;
            --border: #e2e8f0;
            --text: #0f172a;
            --text-muted: #475569;
            --text-faint: #94a3b8;
            --primary: #2563eb;
            --primary-dark: #1d4ed8;
            --primary-50: #eff6ff;
            --danger: #dc2626;
            --danger-50: #fef2f2;
            --danger-border: #fecaca;
            --success: #16a34a;
            --success-50: #f0fdf4;
            --success-border: #bbf7d0;
            --radius-sm: 8px;
            --radius-md: 12px;
            --radius-lg: 20px;
            --shadow-sm: 0 1px 2px hsla(222, 47%, 11%, 0.06);
            --shadow-md: 0 8px 24px hsla(222, 47%, 11%, 0.08), 0 2px 6px hsla(222, 47%, 11%, 0.06);
            --shadow-lg: 0 24px 48px hsla(222, 47%, 11%, 0.12), 0 8px 16px hsla(222, 47%, 11%, 0.06);
            --ease: cubic-bezier(0.4, 0, 0.2, 1);
        }

        @media (prefers-color-scheme: dark) {
            :root {
                --bg: #0b1120;
                --surface: #111827;
                --surface-alt: #0f172a;
                --border: #1f2937;
                --text: #f1f5f9;
                --text-muted: #94a3b8;
                --text-faint: #64748b;
                --primary: #3b82f6;
                --primary-dark: #60a5fa;
                --primary-50: #0b1e3f;
                --danger-50: #2a1212;
                --danger-border: #7f1d1d;
                --success-50: #0f2a18;
                --success-border: #166534;
                --shadow-sm: 0 1px 2px hsla(0, 0%, 0%, 0.3);
                --shadow-md: 0 8px 24px hsla(0, 0%, 0%, 0.4);
                --shadow-lg: 0 24px 48px hsla(0, 0%, 0%, 0.5);
            }
        }

        * { box-sizing: border-box; }

        html { scroll-behavior: smooth; }

        body {
            margin: 0;
            background: var(--bg);
            color: var(--text);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            line-height: 1.6;
            -webkit-font-smoothing: antialiased;
            overflow-x: hidden;
        }

        img { max-width: 100%; display: block; }

        a { color: inherit; }

        .container {
            width: min(1200px, 100% - 2.5rem);
            margin-inline: auto;
        }

        .container-narrow {
            width: min(760px, 100% - 2.5rem);
            margin-inline: auto;
        }

        /* Header */
        .site-header {
            position: sticky;
            top: 0;
            z-index: 50;
            background: hsla(0, 0%, 100%, 0.8);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid var(--border);
        }
        @media (prefers-color-scheme: dark) {
            .site-header { background: hsla(222, 47%, 6%, 0.8); }
        }

        .header-inner {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 0;
            gap: 16px;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 700;
            font-size: 18px;
            letter-spacing: -0.01em;
            text-decoration: none;
            color: var(--text);
        }

        .brand-mark {
            width: 32px;
            height: 32px;
            border-radius: 9px;
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: #fff;
            display: grid;
            place-items: center;
            font-size: 15px;
            font-weight: 800;
            flex-shrink: 0;
        }

        .site-nav {
            display: flex;
            align-items: center;
            gap: 4px;
            flex-wrap: wrap;
        }

        .site-nav a {
            text-decoration: none;
            color: var(--text-muted);
            font-size: 14px;
            font-weight: 600;
            padding: 8px 12px;
            border-radius: var(--radius-sm);
            transition: background 150ms var(--ease), color 150ms var(--ease);
        }

        .site-nav a:hover { background: var(--surface-alt); color: var(--text); }

        .site-nav a.nav-danger { color: var(--danger); }
        .site-nav a.nav-danger:hover { background: var(--danger-50); }

        main { min-height: 60vh; }

        /* Footer */
        .site-footer {
            border-top: 1px solid var(--border);
            padding: 40px 0;
            margin-top: 96px;
        }

        .footer-inner {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
        }

        .footer-inner p {
            margin: 0;
            font-size: 13px;
            color: var(--text-faint);
        }

        .footer-links {
            display: flex;
            flex-wrap: wrap;
            gap: 4px;
        }

        .footer-links a {
            text-decoration: none;
            color: var(--text-muted);
            font-size: 13px;
            font-weight: 600;
            padding: 6px 10px;
            border-radius: var(--radius-sm);
            transition: background 150ms var(--ease), color 150ms var(--ease);
        }

        .footer-links a:hover { background: var(--surface-alt); color: var(--text); }

        /* Buttons */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            min-height: 46px;
            padding: 12px 24px;
            border-radius: var(--radius-sm);
            font-size: 15px;
            font-weight: 600;
            text-decoration: none;
            border: 1px solid transparent;
            cursor: pointer;
            transition: transform 150ms var(--ease), box-shadow 150ms var(--ease), background 150ms var(--ease), border-color 150ms var(--ease);
        }
        .btn:active { transform: translateY(1px); }

        .btn-primary {
            background: var(--primary);
            color: #fff;
            box-shadow: 0 1px 2px hsla(222,80%,40%,0.3), 0 8px 20px hsla(222,80%,50%,0.25);
        }
        .btn-primary:hover { background: var(--primary-dark); }

        .btn-secondary {
            background: var(--surface);
            color: var(--text);
            border-color: var(--border);
        }
        .btn-secondary:hover { background: var(--surface-alt); }

        .btn-danger {
            background: var(--danger);
            color: #fff;
        }
        .btn-danger:hover { background: #b91c1c; }

        .btn:disabled { opacity: 0.5; cursor: not-allowed; }

        .btn-block { width: 100%; }

        /* Cards */
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius-lg);
            box-shadow: var(--shadow-sm);
        }

        /* Forms */
        label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-muted);
            margin-bottom: 6px;
        }

        .field { margin-bottom: 20px; }

        input[type="text"],
        input[type="tel"],
        input[type="password"],
        input[type="email"],
        textarea {
            width: 100%;
            min-height: 46px;
            padding: 12px 14px;
            border-radius: var(--radius-sm);
            border: 1px solid var(--border);
            background: var(--surface);
            color: var(--text);
            font-size: 15px;
            font-family: inherit;
            transition: border-color 150ms var(--ease), box-shadow 150ms var(--ease);
        }

        textarea { min-height: 96px; resize: vertical; }

        input:focus, textarea:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 2px hsla(217, 91%, 60%, 0.25);
        }

        .field-error input,
        .field-error textarea {
            border-color: var(--danger);
        }

        .field-error-text {
            margin-top: 6px;
            font-size: 13px;
            color: var(--danger);
        }

        .checkbox-row {
            display: flex;
            align-items: flex-start;
            gap: 10px;
        }
        .checkbox-row input[type="checkbox"] {
            margin-top: 3px;
            width: 18px;
            height: 18px;
            accent-color: var(--danger);
            flex-shrink: 0;
        }
        .checkbox-row label { margin: 0; font-weight: 500; color: var(--text); font-size: 14px; }

        .alert {
            border-radius: var(--radius-md);
            padding: 16px 18px;
            font-size: 14px;
            margin-bottom: 24px;
            border: 1px solid;
        }
        .alert-danger {
            background: var(--danger-50);
            border-color: var(--danger-border);
            color: var(--danger);
        }
        .alert-danger ul { margin: 4px 0 0; padding-left: 18px; }

        .alert-warning {
            background: #fffbeb;
            border-color: #fde68a;
            color: #92400e;
        }
        @media (prefers-color-scheme: dark) {
            .alert-warning { background: #2a2005; border-color: #92400e; color: #fbbf24; }
        }

        /* Utility */
        .eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 13px;
            font-weight: 700;
            color: var(--primary);
            text-transform: uppercase;
            letter-spacing: 0.06em;
        }

        h1, h2, h3 { letter-spacing: -0.02em; line-height: 1.15; margin: 0; }

        .prose h2 {
            font-size: 22px;
            margin-top: 40px;
            margin-bottom: 12px;
        }
        .prose h2:first-child { margin-top: 0; }
        .prose p, .prose li { color: var(--text-muted); font-size: 15.5px; }
        .prose ul { padding-left: 22px; }
        .prose li { margin-bottom: 8px; }
        .prose strong { color: var(--text); }

        @media (prefers-reduced-motion: reduce) {
            * { animation: none !important; transition: none !important; }
        }
    </style>
    @stack('styles')
</head>
<body>
    <header class="site-header">
        <div class="container header-inner">
            <a href="{{ route('home') }}" class="brand">
                <span class="brand-mark">R</span>
                {{ config('legal.app_name') }}
            </a>
            <nav class="site-nav">
                <a href="{{ route('home') }}">Inicio</a>
                <a href="{{ route('legal.privacy') }}">Privacidad</a>
                <a href="{{ route('legal.terms') }}">Términos</a>
                <a href="{{ route('account.delete.form') }}" class="nav-danger">Eliminar cuenta</a>
            </nav>
        </div>
    </header>

    <main>
        @yield('content')
    </main>

    <footer class="site-footer">
        <div class="container footer-inner">
            <p>&copy; {{ date('Y') }} {{ config('legal.company_name') }}. Todos los derechos reservados.</p>
            <div class="footer-links">
                <a href="{{ route('legal.privacy') }}">Política de privacidad</a>
                <a href="{{ route('legal.terms') }}">Términos y condiciones</a>
                <a href="{{ route('account.delete.form') }}">Eliminar cuenta</a>
                <a href="mailto:{{ config('legal.support_email') }}">Contacto</a>
            </div>
        </div>
    </footer>
</body>
</html>
