<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $table = 'User';
    protected $primaryKey = 'UserId';
    public $timestamps = false;

    protected $fillable = [
        'UserName',
        'LoginName',
        'PhoneNumber',
        'EmailAddress',
    ];

    protected $hidden = [
        'Password',
        'PasswordSalt',
    ];
}
