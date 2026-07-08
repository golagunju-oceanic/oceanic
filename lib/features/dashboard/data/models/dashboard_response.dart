import 'package:oceanic/features/dashboard/data/models/authorization_summary.dart';
import 'package:oceanic/features/dashboard/data/models/member_model.dart';
import 'package:oceanic/features/dashboard/data/models/recent_authorization.dart';

class DashboardResponse {
  final MemberSummary member;
  final AuthorizationSummary authorizations;
  final List<RecentAuthorization> recentAuthorizations;

  DashboardResponse({
    required this.member,
    required this.authorizations,
    required this.recentAuthorizations,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    return DashboardResponse(
      member: MemberSummary.fromJson(data['member']),
      authorizations: AuthorizationSummary.fromJson(
        data['authorizations'],
      ),
      recentAuthorizations:
          (data['recentAuthorizations'] as List)
              .map(
                (e) => RecentAuthorization.fromJson(e),
              )
              .toList(),
    );
  }
}