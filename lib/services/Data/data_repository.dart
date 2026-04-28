import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:pfe_test/services/appwrite_service.dart';

class DataRepository {
  final AppwriteService appwriteService;

  DataRepository({required this.appwriteService});

  Future<RowList> getRows(
      {List<String>? queries, required String tableId}) async {
    try {
      return await appwriteService.databases.listRows(
        databaseId: '6972adad002e2ba515f2',
        tableId: tableId,
        queries: queries,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Row> getRow( {List<String>? queries,required String tableId, required String rowId}) async {
    try {
      return await appwriteService.databases.getRow(
        databaseId: '6972adad002e2ba515f2',
        tableId: tableId,
        rowId: rowId,
        queries: queries
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Row> createRow(
      {String? rowId,
      required String tableId,
      required Map<String, dynamic> data}) async {
    try {
      return await appwriteService.databases.createRow(
        databaseId: '6972adad002e2ba515f2',
        tableId: tableId,
        rowId: rowId ?? ID.unique(),
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Row> updateRow(
      {required String tableId,
      required String rowId,
      required Map<String, dynamic> data}) async {
    try {
      return await appwriteService.databases.updateRow(
        databaseId: '6972adad002e2ba515f2',
        tableId: tableId,
        rowId: rowId,
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRow({
    required String tableId,
    required String rowId,
  }) async {
    try {
       await appwriteService.databases.deleteRow(
        databaseId: '6972adad002e2ba515f2',
        tableId: tableId,
        rowId: rowId,
      );
    } catch (e) {
      rethrow;
    }
  }
}
