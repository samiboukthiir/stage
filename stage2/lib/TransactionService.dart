import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

part 'TransactionService.g.dart';

@RestApi(baseUrl: "http://localhost:8000/api") // Remplacez par l'URL de votre API
abstract class TransactionService {
  factory TransactionService(Dio dio, {String baseUrl}) = _TransactionService;

  @GET("/transactions")
  Future<List<Transaction>> getTransactions();

  @POST("/transactions")
  Future<void> addTransaction(@Body() Map<String, dynamic> data);

  @DELETE("/transactions/{id}")
  Future<void> deleteTransaction(@Path("id") int id);

}

@JsonSerializable()
class Transaction {
  final int id;
  final String name;
  final String amount;
  final String date;

  Transaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
  });



  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}


