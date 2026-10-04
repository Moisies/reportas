<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ExpenseType extends Model
{
    protected $table = 'ExpenseType';
    protected $primaryKey = 'ExpenseTypeId';
    public $timestamps = false;

    protected $fillable = [
        'ExpenseTypeName',
        'DisplayName',
    ];
}
