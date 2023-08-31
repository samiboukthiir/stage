<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\Transaction;

class TransactionController extends Controller
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string',
            'amount' => 'required|numeric',
            'date' => 'required|date',
        ]);

        $transaction = Transaction::create($data);

        return response()->json($transaction, 201);
    }

    public function index()
    {
        $transactions = Transaction::all();

        return response()->json($transactions);
    }

    public function show($id)
    {
        $transaction = Transaction::findOrFail($id);

        return response()->json($transaction);
    }

    public function update(Request $request, $id)
    {
        $transaction = Transaction::findOrFail($id);

        $data = $request->validate([
            'name' => 'required|string',
            'amount' => 'required|numeric',
            'date' => 'required|date',
        ]);

        $transaction->update($data);

        return response()->json($transaction);
    }

    public function destroy($id)
    {
        $transaction = Transaction::findOrFail($id);
        $transaction->delete();

        return response()->json(null, 204);
    }
}
