<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Datos legales / de contacto para la landing page
    |--------------------------------------------------------------------------
    |
    | Usados en la política de privacidad, términos y condiciones, y en el
    | flujo de eliminación de cuenta. Ajusta vía variables de entorno.
    |
    */

    'app_name' => env('LEGAL_APP_NAME', 'ReportAs'),

    'company_name' => env('LEGAL_COMPANY_NAME', 'Rebexa'),

    'support_email' => env('LEGAL_SUPPORT_EMAIL', 'soporte@rebexa.com'),

    'privacy_email' => env('LEGAL_PRIVACY_EMAIL', 'privacidad@rebexa.com'),

    'deletion_sla_days' => env('LEGAL_DELETION_SLA_DAYS', 30),

];
