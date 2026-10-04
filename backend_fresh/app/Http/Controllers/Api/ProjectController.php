<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class ProjectController extends Controller
{
    use ApiResponse;

    // ISO 4217 codes mapped from LocalCurrencyName in REBEXADEV
    private const CURRENCY_MAP = [
        'Florines'                   => 'AWG',
        'Belize Dollar'              => 'BZD',
        'Chilean peso'               => 'CLP',
        'Colombian peso'             => 'COP',
        'Colones'                    => 'CRC',
        'Dominican peso'             => 'DOP',
        'USD'                        => 'USD',
        'USD / Balboa'               => 'USD',
        'Quetzal'                    => 'GTQ',
        'Lempira'                    => 'HNL',
        'Jamaican Dollar'            => 'JMD',
        'Mexican peso'               => 'MXN',
        'Cordobas'                   => 'NIO',
        'Nuevo Sol'                  => 'PEN',
        'Trinidad & Tobago Dollar '  => 'TTD',
        'Bolivar Soberano'           => 'VES',
    ];

    public function index(\Illuminate\Http\Request $request): JsonResponse
    {
        $companyId = $request->query('company_id');

        if ($companyId) {
            $projects = DB::select(
                'EXEC dbo.app_RegentProject @iCurrentUserId = ?, @iCompanyId = ?',
                [auth()->id(), (int) $companyId]
            );
        } else {
            $projects = DB::select(
                'EXEC dbo.app_RegentProject @iCurrentUserId = ?',
                [auth()->id()]
            );
        }

        return $this->success($projects);
    }

    public function currency(int $projectId): JsonResponse
    {
        $result = DB::selectOne("
            SELECT TOP 1
                lc.LocalCurrencyId,
                lc.LocalCurrencyName,
                co.CountryName
            FROM [Project] p
            INNER JOIN [Country] co ON co.CountryId = p.CountryId AND co.DeleteDate IS NULL
            INNER JOIN [LocalCurrency] lc ON lc.CountryId = co.CountryId AND lc.DeleteDate IS NULL
            WHERE p.ProjectId = ? AND p.DeleteDate IS NULL
        ", [$projectId]);

        if (!$result) {
            return $this->notFound('Proyecto no encontrado');
        }

        $isoCode = self::CURRENCY_MAP[trim($result->LocalCurrencyName)] ?? 'USD';

        return $this->success([
            'project_id'            => $projectId,
            'local_currency_id'     => $result->LocalCurrencyId,
            'local_currency_name'   => $result->LocalCurrencyName,
            'iso_code'              => $isoCode,
            'country'               => $result->CountryName,
        ]);
    }
}
