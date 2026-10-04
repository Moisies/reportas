@extends('layouts.app')

@section('title', 'Política de privacidad — ' . config('legal.app_name'))
@section('description', 'Política de privacidad de ' . config('legal.app_name') . ', app interna de ' . config('legal.company_name') . '.')

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
        <h1>Política de privacidad</h1>
        <p class="updated">Última actualización: {{ now()->locale('es')->translatedFormat('d \d\e F \d\e Y') }}</p>
    </div>
</section>

<section class="legal-body">
    <div class="container-narrow card" style="padding: 40px;">
        <div class="prose">
            <p>
                Esta política describe cómo {{ config('legal.company_name') }} recopila, usa y protege la información
                de los usuarios de {{ config('legal.app_name') }}, la aplicación móvil interna utilizada por agentes
                de {{ config('legal.company_name') }} para registrar gastos de campo y sus recibos.
            </p>

            <h2>1. Quiénes pueden usar la app</h2>
            <p>
                {{ config('legal.app_name') }} es una herramienta de uso interno. Solo pueden acceder personas con una
                cuenta de usuario activa, provista y administrada por {{ config('legal.company_name') }}. No está
                disponible para el público general y no permite el autorregistro de nuevas cuentas.
            </p>

            <h2>2. Información que recopilamos</h2>
            <ul>
                <li><strong>Datos de la cuenta:</strong> nombre de usuario, nombre de inicio de sesión, correo electrónico y número de teléfono asociados a tu perfil en {{ config('legal.company_name') }}.</li>
                <li><strong>Datos de gastos:</strong> monto, tipo de gasto, moneda, fecha, descripción, proyecto y compañía relacionados a cada registro.</li>
                <li><strong>Fotografías de recibos:</strong> la imagen del comprobante que adjuntas al registrar un gasto, capturada con la cámara del dispositivo o seleccionada de tu galería.</li>
                <li><strong>Datos del dispositivo:</strong> un identificador de dispositivo y nombre de dispositivo, usados únicamente para habilitar el inicio de sesión con biometría.</li>
                <li><strong>Datos técnicos:</strong> registros de acceso (fecha/hora de inicio de sesión) con fines de seguridad y auditoría.</li>
            </ul>

            <h2>3. Cómo usamos tu información</h2>
            <ul>
                <li>Autenticar tu identidad y darte acceso seguro a la aplicación.</li>
                <li>Registrar y almacenar tus gastos y comprobantes vinculados a los proyectos de {{ config('legal.company_name') }}.</li>
                <li>Permitir el inicio de sesión biométrico en tu propio dispositivo.</li>
                <li>Generar reportes internos de gastos para fines administrativos, contables y de auditoría.</li>
                <li>Detectar y prevenir accesos no autorizados.</li>
            </ul>

            <h2>4. Con quién compartimos la información</h2>
            <p>
                No vendemos ni compartimos tu información con terceros con fines comerciales o publicitarios.
                Los datos se almacenan en la infraestructura de {{ config('legal.company_name') }} y son accesibles
                únicamente por personal autorizado (por ejemplo, administración y contabilidad) que los necesita para
                procesar y auditar los gastos registrados.
            </p>

            <h2>5. Almacenamiento y seguridad</h2>
            <p>
                Los datos de la cuenta, gastos y fotografías de recibos se almacenan en servidores administrados por
                {{ config('legal.company_name') }}. Aplicamos medidas técnicas y organizativas razonables (control de
                acceso, cifrado en tránsito y autenticación) para proteger la información contra accesos, pérdidas o
                alteraciones no autorizadas.
            </p>

            <h2>6. Conservación de datos</h2>
            <p>
                Conservamos los registros de gastos y comprobantes durante el tiempo necesario para cumplir con
                obligaciones contables, fiscales y de auditoría interna, incluso después de que una cuenta haya sido
                dada de baja, salvo que la normativa aplicable exija un plazo distinto.
            </p>

            <h2>7. Tus derechos</h2>
            <p>
                Puedes solicitar acceso, corrección o eliminación de tu información personal, sujeto a las
                obligaciones legales y contables mencionadas en la sección anterior. Para solicitar la eliminación de
                tu cuenta, visita la página <a href="{{ route('account.delete.form') }}">Eliminar cuenta</a>.
                Para cualquier otra solicitud relacionada con tus datos, escríbenos a
                <a href="mailto:{{ config('legal.privacy_email') }}">{{ config('legal.privacy_email') }}</a>.
            </p>

            <h2>8. Permisos del dispositivo</h2>
            <p>
                La app solicita acceso a la <strong>cámara</strong> para fotografiar recibos y, opcionalmente, a la
                <strong>biometría del dispositivo</strong> (huella o rostro) para agilizar el inicio de sesión. Estos
                permisos se usan exclusivamente para las funciones descritas y puedes revocarlos en cualquier momento
                desde la configuración de tu dispositivo.
            </p>

            <h2>9. Cambios a esta política</h2>
            <p>
                Podemos actualizar esta política ocasionalmente para reflejar cambios en la app o en normativa
                aplicable. Notificaremos cambios relevantes actualizando la fecha en la parte superior de esta página.
            </p>

            <h2>10. Contacto</h2>
            <p>
                Si tienes preguntas sobre esta política de privacidad, contáctanos en
                <a href="mailto:{{ config('legal.privacy_email') }}">{{ config('legal.privacy_email') }}</a>
                o <a href="mailto:{{ config('legal.support_email') }}">{{ config('legal.support_email') }}</a>.
            </p>
        </div>
    </div>
</section>
@endsection
