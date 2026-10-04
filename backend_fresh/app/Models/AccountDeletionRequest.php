<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class AccountDeletionRequest extends Model
{
    protected $table = 'account_deletion_requests';

    protected $fillable = [
        'user_id',
        'login_name',
        'phone_number',
        'reason',
        'status',
        'processed_at',
    ];

    protected $casts = [
        'processed_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'UserId');
    }
}
