<?php

namespace App\Services;

use App\Models\Expense;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;

class ExpenseService
{
    public function store(array $data, UploadedFile $image): array
    {
        $result = DB::select(
            'EXEC dbo.app_Expense
                @iExpenseTypeId       = ?,
                @iProjectId           = ?,
                @dExpenseDate         = ?,
                @sDescription         = ?,
                @fLocalCurrencyAmount = ?,
                @fExchangeRate        = ?,
                @iCurrentUserId       = ?',
            [
                $data['expense_type_id'],
                $data['project_id'],
                $data['expense_date'],
                $data['description'] ?? '',
                $data['amount'],
                $data['exchange_rate'] ?? 1.0,
                auth()->id(),
            ]
        );

        $linkToReceipt   = rtrim($result[0]->LinkToReceipt, '\\/');
        $expenseTypeName = $result[0]->ExpenseTypeName;

        // Sanitize filename for Windows (no colons or illegal chars)
        $timestamp = now()->format('Y-m-d_H-i-s-v');
        $safeName  = preg_replace('/[^A-Za-z0-9\-_]/', '_', $expenseTypeName);
        $fileName  = "{$timestamp}_{$safeName}.jpg";

        $fullPath = $linkToReceipt . DIRECTORY_SEPARATOR . $fileName;

        if (!is_dir($linkToReceipt)) {
            mkdir($linkToReceipt, 0755, true);
        }

        file_put_contents($fullPath, file_get_contents($image->getRealPath()));

        return [
            'expense_type_name' => $expenseTypeName,
            'amount'            => $data['amount'],
            'expense_date'      => $data['expense_date'],
            'image_path'        => $fullPath,
        ];
    }

    public function list(int $userId, int $page = 1, int $perPage = 15): array
    {
        $paginator = Expense::where('UserId', $userId)
            ->whereNull('DeleteDate')
            ->orderByDesc('ExpenseDate')
            ->orderByDesc('CreateDate')
            ->paginate($perPage, ['*'], 'page', $page);

        return [
            'data' => $paginator->items(),
            'meta' => [
                'current_page' => $paginator->currentPage(),
                'total'        => $paginator->total(),
                'per_page'     => $paginator->perPage(),
                'last_page'    => $paginator->lastPage(),
            ],
        ];
    }

    public function myReceipts(int $userId): array
    {
        $rows = DB::select(
            'EXEC dbo.app_RegentOpenReceipts @iCurrentUserId = ?',
            [$userId]
        );

        return array_map(fn ($row) => [
            'expense_id'        => (int) $row->ExpenseId,
            'project_id'        => (int) $row->ProjectId,
            'project_name'      => $row->ProjectName,
            'expense_type_id'   => (int) $row->ExpenseTypeId,
            'expense_type_name' => $row->ExpenseTypeName,
            'amount'            => (float) $row->LocalCurrencyAmount,
            'exchange_rate'     => (float) $row->ExchangeRate,
            'expense_date'      => $row->ExpenseDate,
            'description'       => $row->Description,
        ], $rows);
    }

    public function deleteReceipt(int $expenseId, int $userId): void
    {
        DB::statement(
            'EXEC dbo.app_RegentOpenReceipts @sType = ?, @iExpenseId = ?, @iCurrentUserId = ?',
            ['Del', $expenseId, $userId]
        );
    }
}
