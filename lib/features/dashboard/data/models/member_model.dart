class MemberSummary {
  final String memberId;
  final String fullName;

  MemberSummary({
    required this.memberId,
    required this.fullName,
  });

  factory MemberSummary.fromJson(Map<String, dynamic> json) {
    return MemberSummary(
      memberId: json['memberId'],
      fullName: json['fullName'],
    );
  }
}