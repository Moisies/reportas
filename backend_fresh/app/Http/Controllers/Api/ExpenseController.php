<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreExpenseRequest;
use App\Models\Expense;
use App\Services\ExpenseService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class ExpenseController extends Controller
{
    use ApiResponse;

    public function __construct(private ExpenseService $expenseService) {}

    public function store(StoreExpenseRequest $request): JsonResponse
    {
        $result = $this->expenseService->store(
            $request->validated(),
            $request->file('receipt_image')
        );

        return $this->created($result, 'Gasto registrado correctamente');
    }

    public function index(Request $request): JsonResponse
    {
        $result = $this->expenseService->list(auth()->id(), $request->integer('page', 1));

        return response()->json([
            'success' => true,
            'data'    => $result['data'],
            'meta'    => $result['meta'],
        ]);
    }

    public function myReceipts(): JsonResponse
    {
        $receipts = $this->expenseService->myReceipts(auth()->id());

        $data = array_map(function (array $receipt) {
            $receipt['receipt_image_url'] = route('api.expenses.receipt-image', $receipt['expense_id']);
            return $receipt;
        }, $receipts);

        return $this->success($data);
    }

    public function destroy(int $id): JsonResponse
    {
        $this->expenseService->deleteReceipt($id, auth()->id());

        return $this->success(null, 'Recibo eliminado');
    }

    public function receiptImage(int $id): BinaryFileResponse|Response
    {
        $expense = Expense::where('ExpenseId', $id)
            ->where('UserId', auth()->id())
            ->whereNull('DeleteDate')
            ->first();

        if (!$expense || !$expense->LinkToReceipt || !is_file($expense->LinkToReceipt)) {
            return response('', 404);
        }

        return response()->file($expense->LinkToReceipt);
    }
}
