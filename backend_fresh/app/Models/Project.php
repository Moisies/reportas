<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Project extends Model
{
    protected $table = 'Project';
    protected $primaryKey = 'ProjectId';
    public $timestamps = false;

    protected $fillable = [
        'ProjectId',
        'LocalTradeName',
        'ProjectCode',
    ];
}
