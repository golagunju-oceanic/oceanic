import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oceanic/features/dashboard/data/models/dashboard_response.dart';
import 'package:oceanic/features/dashboard/presentation/providers/dashboard_provider.dart';

class DashboardViewModel extends AsyncNotifier<DashboardResponse> {
  @override
  Future<DashboardResponse> build() async {
    return await ref.read(getDashboardUseCaseProvider)();
  }

  Future<void> refreshDashboard() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(getDashboardUseCaseProvider)(),
    );
  }
}
