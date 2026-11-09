import 'package:dio/dio.dart';

import 'package:oceanic/core/network/api_client.dart';
import 'package:oceanic/core/network/network_exception.dart';
import 'package:oceanic/features/healthrecords/data/models/health_record_model.dart';



class HealthRecordRemoteDatasource {
  final ApiClient apiClient;

  HealthRecordRemoteDatasource(
    this.apiClient,
  );

  Future<List<HealthRecordModel>> getHealthRecords() async {
    try {
      final response = await apiClient.get(
        '/records',
      );

      final responseData = response.data;

      if (responseData is! Map) {
        throw const FormatException(
          'Invalid health records response.',
        );
      }

      final data = Map<String, dynamic>.from(
        responseData,
      );

      final rawRecords = data['records'];

      // The API is allowed to return:
      //
      // {
      //   "count": 0,
      //   "records": []
      // }
      //
      // This is a successful response.

      if (rawRecords == null) {
        return [];
      }

      if (rawRecords is! List) {
        throw const FormatException(
          'Health records field is not a list.',
        );
      }

      final records = <HealthRecordModel>[];

      for (final item in rawRecords) {
        if (item is! Map) {
          continue;
        }

        final json = Map<String, dynamic>.from(
          item,
        );

        records.add(
          HealthRecordModel.fromJson(
            json,
          ),
        );
      }

      return records;
    } on DioException catch (error) {
      throw NetworkException.fromDio(
        error,
      );
    }
  }
}