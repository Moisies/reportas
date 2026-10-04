@extends('layouts.app')

@section('title', config('legal.app_name') . ' — Gastos y recibos en campo | ' . config('legal.company_name'))
@section('description', 'ReportAs es la app interna de ' . config('legal.company_name') . ' para que los agentes registren gastos con evidencia fotográfica, vinculados a proyectos y compañías.')

@push('styles')
<style>
    .hero {
        position: relative;
        padding: 88px 0 96px;
        overflow: hidden;
    }
    .hero::before {
        content: "";
        position: absolute;
        inset: -20% -10% auto -10%;
        height: 480px;
        background: radial-gradient(60% 60% at 50% 0%, hsla(217, 91%, 60%, 0.16), transparent 70%);
        pointer-events: none;
    }
    .hero-inner {
        position: relative;
        display: grid;
        grid-template-columns: 1.1fr 0.9fr;
        gap: 48px;
        align-items: center;
    }
    .hero h1 {
        font-size: clamp(2.1rem, 4vw, 3.2rem);
        margin: 16px 0 20px;
    }
    .hero p.lead {
        font-size: 18px;
        color: var(--text-muted);
        max-width: 46ch;
        margin: 0 0 32px;
    }
    .hero-actions { display: flex; flex-wrap: wrap; gap: 12px; }

    .hero-visual {
        position: relative;
    }
    .phone-mock {
        margin-inline: auto;
        width: min(280px, 100%);
        aspect-ratio: 9 / 18.5;
        background: linear-gradient(160deg, var(--surface), var(--surface-alt));
        border: 1px solid var(--border);
        border-radius: 34px;
        box-shadow: var(--shadow-lg);
        padding: 14px;
        display: flex;
        flex-direction: column;
        gap: 10px;
    }
    .phone-mock .status-bar { height: 8px; }
    .phone-mock .app-bar {
        background: var(--primary);
        border-radius: 12px;
        height: 44px;
        display: flex;
        align-items: center;
        padding: 0 14px;
        color: #fff;
        font-weight: 700;
        font-size: 13px;
    }
    .phone-mock .expense-row {
        background: var(--surface);
        border: 1px solid var(--border);
        border-radius: 12px;
        padding: 10px 12px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        font-size: 12px;
    }
    .phone-mock .expense-row .thumb {
        width: 30px; height: 30px; border-radius: 8px;
        background: var(--primary-50);
        flex-shrink: 0;
        margin-right: 10px;
    }
    .phone-mock .expense-row .meta { flex: 1; min-width: 0; }
    .phone-mock .expense-row .meta strong { display: block; font-size: 12.5px; color: var(--text); }
    .phone-mock .expense-row .meta span { color: var(--text-faint); font-size: 11px; }
    .phone-mock .expense-row .amount { font-weight: 700; color: var(--text); font-size: 12.5px; }
    .phone-mock .fab {
        margin-top: auto;
        align-self: flex-end;
        width: 46px; height: 46px;
        border-radius: 50%;
        background: var(--primary);
        color: #fff;
        display: grid;
        place-items: center;
        font-size: 22px;
        font-weight: 700;
        box-shadow: var(--shadow-md);
    }

    .section { padding: 64px 0; }
    .section-head { text-align: center; max-width: 640px; margin: 0 auto 48px; }
    .section-head h2 { font-size: clamp(1.6rem, 3vw, 2.1rem); margin-top: 12px; }
    .section-head p { color: var(--text-muted); font-size: 16px; margin-top: 12px; }

    .feature-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 20px;
    }
    .feature-card {
        padding: 28px;
    }
    .feature-icon {
        width: 44px; height: 44px;
        border-radius: 12px;
        background: var(--primary-50);
        color: var(--primary);
        display: grid;
        place-items: center;
        margin-bottom: 16px;
        font-size: 20px;
    }
    .feature-card h3 { font-size: 16.5px; margin-bottom: 8px; }
    .feature-card p { margin: 0; color: var(--text-muted); font-size: 14.5px; }

    .band {
        background: var(--surface-alt);
        border-top: 1px solid var(--border);
        border-bottom: 1px solid var(--border);
    }

    .legal-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 20px;
    }
    .legal-card {
        padding: 28px;
        text-decoration: none;
        display: block;
        transition: transform 200ms var(--ease), box-shadow 200ms var(--ease);
    }
    .legal-card:hover { transform: translateY(-3px); box-shadow: var(--shadow-md); }
    .legal-card h3 { font-size: 16px; color: var(--text); margin-bottom: 6px; }
    .legal-card p { margin: 0; color: var(--text-muted); font-size: 14px; }
    .legal-card .arrow { margin-top: 14px; font-size: 13px; font-weight: 700; color: var(--primary); }
    .legal-card.danger .arrow { color: var(--danger); }

    @media (max-width: 900px) {
        .hero-inner { grid-template-columns: 1fr; }
        .hero-visual { order: -1; max-width: 280px; margin: 0 auto; }
        .feature-grid, .legal-grid { grid-template-columns: 1fr; }
    }
</style>
@endpush

@section('content')

<section class="hero">
    <div class="container hero-inner">
        <div>
            <span class="eyebrow">Uso interno · {{ config('legal.company_name') }}</span>
            <h1>Gastos de campo, registrados en segundos.</h1>
            <p class="lead">
                {{ config('legal.app_name') }} es la app móvil con la que los agentes de {{ config('legal.company_name') }}
                registran gastos, adjuntan la foto del recibo y los vinculan al proyecto y compañía correctos,
                todo desde el celular.
            </p>
            <div class="hero-actions">
                <a href="{{ route('legal.privacy') }}" class="btn btn-primary">Política de privacidad</a>
                <a href="{{ route('legal.terms') }}" class="btn btn-secondary">Términos y condiciones</a>
            </div>
        </div>
        <div class="hero-visual">
            <div class="phone-mock" aria-hidden="true">
                <div class="app-bar">{{ config('legal.app_name') }}</div>
                <div class="expense-row">
                    <div style="display:flex;align-items:center;min-width:0;">
                        <div class="thumb"></div>
                        <div class="meta"><strong>Sellos</strong><span>Proyecto Norte</span></div>
                    </div>
                    <div class="amount">$42.00</div>
                </div>
                <div class="expense-row">
                    <div style="display:flex;align-items:center;min-width:0;">
                        <div class="thumb"></div>
                        <div class="meta"><strong>Traducciones</strong><span>Proyecto Sur</span></div>
                    </div>
                    <div class="amount">$18.50</div>
                </div>
                <div class="expense-row">
                    <div style="display:flex;align-items:center;min-width:0;">
                        <div class="thumb"></div>
                        <div class="meta"><strong>Gastos legales</strong><span>Proyecto Centro</span></div>
                    </div>
                    <div class="amount">$120.00</div>
                </div>
                <div class="fab">+</div>
            </div>
        </div>
    </div>
</section>

<section class="section">
    <div class="container">
        <div class="section-head">
            <span class="eyebrow">Qué hace</span>
            <h2>Todo lo que un agente necesita en terreno</h2>
            <p>Diseñada para trabajo rápido en campo, con sincronización directa al sistema de {{ config('legal.company_name') }}.</p>
        </div>
        <div class="feature-grid">
            <div class="card feature-card">
                <div class="feature-icon">📷</div>
                <h3>Foto de recibo</h3>
                <p>Cada gasto se registra con evidencia fotográfica del recibo, guardada de forma segura y vinculada al gasto.</p>
            </div>
            <div class="card feature-card">
                <div class="feature-icon">🗂️</div>
                <h3>Proyectos y compañías</h3>
                <p>Vincula cada gasto al proyecto y compañía correspondiente, tomados directamente del sistema de {{ config('legal.company_name') }}.</p>
            </div>
            <div class="card feature-card">
                <div class="feature-icon">🔐</div>
                <h3>Acceso con huella</h3>
                <p>Inicia sesión de forma rápida y segura con biometría, sin exponer tu contraseña en cada uso.</p>
            </div>
        </div>
    </div>
</section>

<section class="section band">
    <div class="container">
        <div class="section-head">
            <span class="eyebrow">Información legal</span>
            <h2>Transparencia y control sobre tus datos</h2>
            <p>Como app publicada en Google Play, ponemos a tu disposición esta información sin necesidad de instalar la app.</p>
        </div>
        <div class="legal-grid">
            <a href="{{ route('legal.privacy') }}" class="card legal-card">
                <h3>Política de privacidad</h3>
                <p>Qué datos recopilamos, para qué los usamos y cómo los protegemos.</p>
                <div class="arrow">Leer política →</div>
            </a>
            <a href="{{ route('legal.terms') }}" class="card legal-card">
                <h3>Términos y condiciones</h3>
                <p>Reglas de uso de {{ config('legal.app_name') }} para agentes de {{ config('legal.company_name') }}.</p>
                <div class="arrow">Leer términos →</div>
            </a>
            <a href="{{ route('account.delete.form') }}" class="card legal-card danger">
                <h3>Eliminar cuenta</h3>
                <p>Solicita la eliminación de tu cuenta y tus datos asociados desde este sitio.</p>
                <div class="arrow">Solicitar eliminación →</div>
            </a>
        </div>
    </div>
</section>

@endsection
