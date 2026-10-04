<?php

namespace App\Http\Controllers;

use App\Http\Requests\DeleteAccountRequest;
use App\Models\AccountDeletionRequest;
use App\Models\UserDevice;
use App\Services\AuthService;
use Illuminate\Http\RedirectResponse;
use Illuminate\View\View;

class AccountDeletionController extends Controller
{
    public function __construct(private AuthService $authService) {}

    public function create(): View
    {
        return view('account.delete');
    }

    public function store(DeleteAccountRequest $request): RedirectResponse
    {
        $user = $this->authService->login(
            $request->login_name,
            $request->password,
            $request->phone_number
        );

        if (!$user) {
            return back()
                ->withInput($request->except('password'))
                ->withErrors(['login_name' => 'No pudimos verificar tus credenciales. Revisa usuario, contraseña y teléfono.']);
        }

        AccountDeletionRequest::create([
            'user_id'      => $user->UserId,
            'login_name'   => $user->LoginName,
            'phone_number' => $request->phone_number,
            'reason'       => $request->reason,
            'status'       => 'pending',
        ]);

        $user->tokens()->delete();
        UserDevice::where('user_id', $user->UserId)->delete();

        return redirect()->route('account.delete.success');
    }
}
