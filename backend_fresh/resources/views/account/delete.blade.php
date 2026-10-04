@extends('layouts.app')

@section('title', 'Eliminar cuenta — ' . config('legal.app_name'))
@section('description', 'Solicita la eliminación de tu cuenta de ' . config('legal.app_name') . '.')

@push('styles')
<style>
    .delete-hero { padding: 56px 0 8px; }
    .delete-hero h1 { font-size: clamp(1.8rem, 3.5vw, 2.2rem); margin-top: 12px; }
    .delete-body { padding: 32px 0 64px; }
    .delete-layout {
        display: grid;
        grid-template-columns: 0.9fr 1.1fr;
        gap: 24px;
        align-items: start;
    }
    .info-list { list-style: none; margin: 0; padding: 0; display: grid; gap: 14px; }
    .info-list li { display: flex; gap: 10px; font-size: 14px; color: var(--text-muted); }
    .info-list li .dot {
        width: 20px; height: 20px; border-radius: 50%;
        background: var(--danger-50); color: var(--danger);
        display: grid; place-items: center; font-size: 12px; font-weight: 700; flex-shrink: 0; margin-top: 1px;
    }
    @media (max-width: 900px) {
        .delete-layout { grid-template-columns: 1fr; }
    }
</style>
@endpush

@section('content')
<section class="delete-hero">
    <div class="container-narrow">
        <span class="eyebrow" style="color: var(--danger);">Eliminar cuenta</span>
        <h1>Solicitar la eliminación de tu cuenta</h1>
    </div>
</section>

<section class="delete-body">
    <div class="container-narrow">
        <div class="delete-layout">
            <div class="card" style="padding: 28px;">
                <h3 style="margin-bottom: 16px; font-size: 15px;">Qué pasa al enviar la solicitud</h3>
                <ul class="info-list">
                    <li><span class="dot">1</span> Verificamos tu identidad con las mismas credenciales que usas en la app.</li>
                    <li><span class="dot">2</span> Cerramos tu sesión activa y desactivamos el inicio biométrico en tus dispositivos.</li>
                    <li><span class="dot">3</span> Tu solicitud queda registrada para ser procesada por un administrador de {{ config('legal.company_name') }}.</li>
                    <li><span class="dot">4</span> Los datos de gastos y comprobantes se conservan el tiempo requerido por obligaciones contables y de auditoría, tal como se explica en la <a href="{{ route('legal.privacy') }}">política de privacidad</a>.</li>
                </ul>
                <div class="alert alert-warning" style="margin-top: 20px; margin-bottom: 0;">
                    El procesamiento puede tardar hasta {{ config('legal.deletion_sla_days') }} días. Si necesitas ayuda,
                    escribe a <a href="mailto:{{ config('legal.support_email') }}">{{ config('legal.support_email') }}</a>.
                </div>
            </div>

            <div class="card" style="padding: 28px;">
                @if ($errors->any())
                    <div class="alert alert-danger">
                        <strong>No pudimos procesar tu solicitud:</strong>
                        <ul>
                            @foreach ($errors->all() as $error)
                                <li>{{ $error }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endif

                <form method="POST" action="{{ route('account.delete.submit') }}" novalidate>
                    @csrf

                    <div class="field @error('login_name') field-error @enderror">
                        <label for="login_name">Usuario (nombre de inicio de sesión)</label>
                        <input type="text" id="login_name" name="login_name" value="{{ old('login_name') }}" autocomplete="username" required>
                    </div>

                    <div class="field @error('phone_number') field-error @enderror">
                        <label for="phone_number">Número de teléfono registrado</label>
                        <input type="tel" id="phone_number" name="phone_number" value="{{ old('phone_number') }}" autocomplete="tel" required>
                    </div>

                    <div class="field @error('password') field-error @enderror">
                        <label for="password">Contraseña</label>
                        <input type="password" id="password" name="password" autocomplete="current-password" required>
                    </div>

                    <div class="field">
                        <label for="reason">Motivo (opcional)</label>
                        <textarea id="reason" name="reason" placeholder="Cuéntanos por qué quieres eliminar tu cuenta">{{ old('reason') }}</textarea>
                    </div>

                    <div class="field @error('confirm') field-error @enderror">
                        <div class="checkbox-row">
                            <input type="checkbox" id="confirm" name="confirm" value="1" {{ old('confirm') ? 'checked' : '' }} required>
                            <label for="confirm">Entiendo que esta acción cerrará mi sesión y solicitará la eliminación de mi cuenta y datos asociados, sujeto a las obligaciones legales descritas en la política de privacidad.</label>
                        </div>
                        @error('confirm')
                            <div class="field-error-text">{{ $message }}</div>
                        @enderror
                    </div>

                    <button type="submit" class="btn btn-danger btn-block">Solicitar eliminación de cuenta</button>
                </form>
            </div>
        </div>
    </div>
</section>
@endsection
