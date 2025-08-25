import 'dart:convert';

List<CheckoutRewards> checkoutRewardFromJson(String str) =>
    List<CheckoutRewards>.from(
      json.decode(str).map((x) => CheckoutRewards.fromJson(x)),
    );

class CheckoutRewards {
  final int id;
  final int ownerId;
  final String rewardType;
  final num amount;
  final int points;
  final int status;
  final int rewardRules;
  final int rewardCapped;
  final int count;
  final DateTime createdAt;
  final DateTime updatedAt;

  CheckoutRewards({
    required this.id,
    required this.ownerId,
    required this.rewardType,
    required this.amount,
    required this.points,
    required this.status,
    required this.rewardRules,
    required this.rewardCapped,
    required this.count,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CheckoutRewards.fromJson(Map<String, dynamic> json) =>
      CheckoutRewards(
        id: json['id'],
        ownerId: json['owner_id'],
        rewardType: json['reward_type'],
        amount: json['amount'],
        points: json['points'],
        status: json['status'],
        rewardRules: json['reward_rules'],
        rewardCapped: json['reward_capped'],
        count: json['count'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  String get description {
    if (rewardType == 'percent') {
      return 'Discount $amount% by exchanging $points point.';
    } else if (rewardType == 'flat') {
      return 'Discount Rp ${rewardRules.toString()} by exchanging $points points.';
    }
    return 'Special Rewards';
  }
}
