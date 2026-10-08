import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../env/env.dart';
import '../main.dart';
import '../utility/uiutils.dart';
import 'api_client.dart';
import 'models/referral_model.dart';

class ReferralProvider with ChangeNotifier {
  ReferralMe? me;
  List<ReferralInvite> invites = [];
  List<ReferralReward> rewards = [];

  bool loadingMe = false;
  bool loadingInvites = false;
  bool loadingRewards = false;
  bool hasNextInvitesPage = false;
  int _invitesPage = 1;

  /// Rewards still to be claimed, which is what the balance on screen shows.
  List<ReferralReward> get unclaimedRewards =>
      rewards.where((r) => r.isUnclaimed).toList();

  /// Total unclaimed reward amount, displayed as XP.
  num get availableReward =>
      unclaimedRewards.fold<num>(0, (sum, r) => sum + (r.token ?? 0));

  bool get hasClaimable => unclaimedRewards.isNotEmpty;

  /// Everything the invite screen needs, in one call.
  Future<void> loadAll() async {
    await Future.wait([
      getMe(),
      getInvites(refresh: true),
      getRewards(),
    ]);
  }

  Future<void> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    loadingMe = true;
    notifyListeners();
    try {
      final response = await apiClient.get(
        Uri.parse("${Env.BACKEND_URL}/referral/me"),
        headers: _headers(prefs),
      );
      if (_ok(response.statusCode)) {
        me = ReferralMeModel.fromJson(jsonDecode(response.body)).data;
      } else if (response.statusCode != 401) {
        print('Referral me failed: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Referral me error: $error');
    } finally {
      loadingMe = false;
      notifyListeners();
    }
  }

  Future<void> getInvites({bool refresh = false}) async {
    if (loadingInvites) return;
    if (!refresh && !hasNextInvitesPage && invites.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (refresh) _invitesPage = 1;
    final page = _invitesPage;

    loadingInvites = true;
    notifyListeners();
    try {
      final response = await apiClient.get(
        Uri.parse(
            "${Env.BACKEND_URL}/referral/invites?page=$page&pageSize=20"),
        headers: _headers(prefs),
      );
      if (_ok(response.statusCode)) {
        final parsed = ReferralInvitesModel.fromJson(jsonDecode(response.body));
        final fetched = parsed.record ?? [];
        if (refresh || page == 1) {
          invites = fetched;
        } else {
          invites.addAll(fetched);
        }
        hasNextInvitesPage = parsed.hasNextPage ?? false;
        if (hasNextInvitesPage) _invitesPage = page + 1;
      } else if (response.statusCode != 401) {
        print('Referral invites failed: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Referral invites error: $error');
    } finally {
      loadingInvites = false;
      notifyListeners();
    }
  }

  Future<void> getRewards() async {
    final prefs = await SharedPreferences.getInstance();
    loadingRewards = true;
    notifyListeners();
    try {
      final response = await apiClient.get(
        Uri.parse("${Env.BACKEND_URL}/referral/rewards"),
        headers: _headers(prefs),
      );
      if (_ok(response.statusCode)) {
        rewards = ReferralRewardsModel.fromJson(jsonDecode(response.body)).data ?? [];
      } else if (response.statusCode != 401) {
        print('Referral rewards failed: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      print('Referral rewards error: $error');
    } finally {
      loadingRewards = false;
      notifyListeners();
    }
  }

  /// Claims every unclaimed reward, crediting them to the wallet.
  ///
  /// The API claims one reward at a time, but the screen shows a single
  /// balance, so claiming it means claiming them all. Returns how many went
  /// through — a partial result is reported honestly rather than as success.
  Future<int> claimAllRewards() async {
    final toClaim = unclaimedRewards;
    int claimed = 0;
    for (final reward in toClaim) {
      if (reward.id == null) continue;
      if (await _claimOne(reward.id!)) claimed++;
    }
    await getRewards();
    return claimed;
  }

  Future<bool> _claimOne(String rewardId) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await apiClient.post(
        Uri.parse("${Env.BACKEND_URL}/referral/rewards/$rewardId/claim"),
        headers: _headers(prefs),
      );
      if (_ok(response.statusCode)) return true;
      if (response.statusCode != 401) {
        print('Claim reward failed: ${response.statusCode} ${response.body}');
      }
      return false;
    } catch (error) {
      print('Claim reward error: $error');
      return false;
    }
  }

  bool _ok(int code) => code == 200 || code == 201;

  Map<String, String> _headers(SharedPreferences prefs) => {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': "Bearer ${prefs.getString('accessToken')}",
      };

  void alert(String title, String content) {
    UiUtils.showAlertDialog(
      context: globalNavigatorKey.currentContext!,
      title: title,
      content: content,
      defaultActionText: 'close',
      onDismissed: (_) {},
    );
  }
}
