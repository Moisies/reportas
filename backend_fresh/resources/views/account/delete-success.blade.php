@extends('layouts.app')

@section('title', 'Solicitud recibida — ' . config('legal.app_name'))

@push('styles')
<style>
    .success-wrap { padding: 96px 0; text-align: center; }
    .success-icon {
        width: 64px; height: 64px; border-radius: 50%;
        background: var(--success-50); color: var(--success);
        display: grid; place-items: center; margin: 0 auto 20px;
        font-size: 30px; border: 1px solid var(--success-border);
    }
    .success-wrap h1 { font-size: clamp(1.6rem, 3vw, 2rem); margin-bottom: 12px; }
    .success-wrap p { color: var(--text-muted); max-width: 46ch; margin: 0 auto 28px; }
</style>
@endpush

@section('content')
<section class="success-wrap">
    <div class="container-narrow">
        <div class="success-icon">✓</div>
        <h1>Solicitud de eliminación recibida</h1>
        <p>
            Verificamos tu identidad y registramos tu solicitud. Cerramos tu sesión y desactivamos el acceso
            biométrico en tus dispositivos. Un administrador de {{ config('legal.company_name') }} procesará tu
            solicitud en un plazo de hasta {{ config('legal.deletion_sla_days') }} días.
        </p>
        <p>
            ¿Preguntas? Escríbenos a
            <a href="mailto:{{ config('legal.support_email') }}">{{ config('legal.support_email') }}</a>.
        </p>
        <a href="{{ route('home') }}" class="btn btn-secondary">Volver al inicio</a>
    </div>
</section>
@endsection
