enum ApprovalStatus {
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED');

  final String value;
  const ApprovalStatus(this.value);

  factory ApprovalStatus.fromString(String status) {
    return ApprovalStatus.values.firstWhere(
      (e) => e.value == status.toUpperCase(),
      orElse: () => ApprovalStatus.pending,
    );
  }

  @override
  String toString() => value;
}