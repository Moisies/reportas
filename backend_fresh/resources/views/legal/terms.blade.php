@extends('layouts.app')

@section('title', 'Términos y condiciones — ' . config('legal.app_name'))
@section('description', 'Términos y condiciones de uso de ' . config('legal.app_name') . ', app interna de ' . config('legal.company_name') . '.')

@push('styles')
<style>
    .legal-hero { padding: 56px 0 24px; }
    .legal-hero h1 { font-size: clamp(1.8rem, 3.5vw, 2.4rem); margin-top: 12px; }
    .legal-hero .updated { color: var(--text-faint); font-size: 13px; margin-top: 10px; }
    .legal-body { padding-bottom: 64px; }
</style>
@endpush

@section('content')
<section class="legal-hero">
    <div class="container-narrow">
        <span class="eyebrow">Legal</span>
        <h1>Términos y condiciones</h1>
        <p class="updated">Última actualización: {{ now()->locale('es')->translatedFormat('d \d\e F \d\e Y') }}</p>
    </div>
</section>

<section class="legal-body">
    <div class="container-narrow card" style="padding: 40px;">
        <div class="prose">
            <p>
                Estos términos rigen el uso de {{ config('legal.app_name') }} (la "app"), una herramienta interna
                desarrollada y operada por {{ config('legal.company_name') }} para el registro de gastos de campo por
                parte de sus agentes. Al iniciar sesión y usar la app, aceptas estos términos.
            </p>

            <h2>1. Elegibilidad y cuentas</h2>
            <p>
                El acceso a {{ config('legal.app_name') }} está restringido a personas autorizadas por
                {{ config('legal.company_name') }}. Las cuentas son provistas por la organización; no es posible
                registrarse por cuenta propia. Eres responsable de mantener la confidencialidad de tus credenciales
                y de todas las acciones realizadas desde tu cuenta.
            </p>

            <h2>2. Uso permitido</h2>
            <ul>
                <li>Registrar gastos reales, con montos y descripciones veraces.</li>
                <li>Adjuntar únicamente comprobantes auténticos y correspondientes al gasto registrado.</li>
                <li>Usar la app exclusivamente para fines relacionados con tus funciones en {{ config('legal.company_name') }}.</li>
            </ul>

            <h2>3. Uso prohibido</h2>
            <ul>
                <li>Registrar gastos falsos, duplicados o con documentación adulterada.</li>
                <li>Compartir tus credenciales de acceso o el token biométrico de tu dispositivo con terceros.</li>
                <li>Intentar acceder a cuentas, proyectos o información de otros usuarios sin autorización.</li>
                <li>Realizar ingeniería inversa, interferir con el funcionamiento de la app o vulnerar sus medidas de seguridad.</li>
            </ul>

            <h2>4. Propiedad</h2>
            <p>
                La app, su código, diseño y marca son propiedad de {{ config('legal.company_name') }}. Los gastos,
                comprobantes y demás información registrada por los usuarios pertenecen a {{ config('legal.company_name') }}
                y forman parte de sus registros contables y administrativos.
            </p>

            <h2>5. Disponibilidad del servicio</h2>
            <p>
                Procuramos mantener {{ config('legal.app_name') }} disponible y en buen funcionamiento, pero no
                garantizamos un servicio ininterrumpido. Podemos suspender el acceso por mantenimiento, actualizaciones
                o motivos de seguridad, con o sin previo aviso.
            </p>

            <h2>6. Suspensión y baja de cuentas</h2>
            <p>
                {{ config('legal.company_name') }} puede suspender o desactivar tu acceso a la app si dejas de ser
                agente autorizado, por uso indebido de la aplicación, o a tu solicitud a través de la página
                <a href="{{ route('account.delete.form') }}">Eliminar cuenta</a>.
            </p>

            <h2>7. Limitación de responsabilidad</h2>
            <p>
                {{ config('legal.company_name') }} no será responsable por daños indirectos derivados del uso o la
                imposibilidad de uso de la app, salvo en los casos en que la ley aplicable no permita dicha limitación.
            </p>

            <h2>8. Cambios a estos términos</h2>
            <p>
                Podemos modificar estos términos en cualquier momento. Los cambios entran en vigor al publicarse en
                esta página, indicando la fecha de última actualización.
            </p>

            <h2>9. Contacto</h2>
            <p>
                Para preguntas sobre estos términos, escríbenos a
                <a href="mailto:{{ config('legal.support_email') }}">{{ config('legal.support_email') }}</a>.
            </p>
        </div>
    </div>
</section>
@endsection
