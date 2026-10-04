<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Expense extends Model
{
    protected $table = 'Expense';
    protected $primaryKey = 'ExpenseId';
    public $timestamps = false;

    protected $fillable = [
        'ExpenseTypeId',
        'ProjectId',
        'UserId',
        'LocalCurrencyId',
        'ExpenseDate',
        'Description',
        'LocalCurrencyAmount',
        'ExchangeRate',
        'Amount',
        'LinkToReceipt',
        'CreateDate',
        'ModifyDate',
    ];

    protected $casts = [
        'ExpenseDate'  => 'date',
        'CreateDate'   => 'datetime',
        'ModifyDate'   => 'datetime',
        'DeleteDate'   => 'datetime',
    ];

    public function expenseType()
    {
        return $this->belongsTo(ExpenseType::class, 'ExpenseTypeId', 'ExpenseTypeId');
    }
}
