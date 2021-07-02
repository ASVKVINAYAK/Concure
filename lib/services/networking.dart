
import 'package:covid19_tracker/model/covid19_dashboard.dart';
import 'package:covid19_tracker/model/distict_list.dart';
import 'package:covid19_tracker/model/serializers.dart';
import 'package:covid19_tracker/model/state_list.dart';
import 'package:covid19_tracker/screens/slot_booking.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Networking {
  final box = GetStorage('MyStorage');

  Future<Covid19Dashboard> getDashboardData() async {
    Covid19Dashboard _dashboardResult;
    var url = 'https://doh.saal.ai/api/live';

    var response = await http.get(url);


    if (response.statusCode == 200) {
      dynamic data = jsonDecode(response.body);
      _dashboardResult =
          serializers.deserializeWith(Covid19Dashboard.serializer, data);
    } else {
      throw Exception('connection error');
    }
    return _dashboardResult;
  }

  get_notified() async {
    var url1 = Uri.parse(
        'https://cdn-api.co-vin.in/api/v2/admin/location/states');
    var response1 = await http.get(url1);
    // print("res ${response.body}");
    if (response1.statusCode == 200) {
      final stateList = stateListFromJson(response1.body);
      SharedPreferences pref = await SharedPreferences.getInstance();
      String sn=pref.getString('state_name')??"";
      List<State> s = stateList.states;
      for (int i = 0; i < s.length; ++i) {
        if (sn == s[i].stateName) {
          await box.write('state_id', s[i].stateId.toString());
          await pref.setString('state_id', s[i].stateId.toString());
        }
      }
    } else {
      throw Exception('Unexpected error occured!');
    }
    SharedPreferences pref = await SharedPreferences.getInstance();
    String si=pref.getString('state_id')??"";
    var url2 = Uri.parse(
        'https://cdn-api.co-vin.in/api/v2/admin/location/districts/${si}');
    var response2 = await http.get(url2);
    print(response2.body);
    final distictsList = distictsListFromJson(response2.body);
    List<District> d = distictsList.districts;
    String dn=pref.getString('district_name')??"";
    for (int i = 0; i < d.length; ++i) {

      if (dn== d[i].districtName) {
        pref.setString('district_id', '${d[i].districtId}');
        box.write('district_id', '${d[i].districtId}');
        print("Share pref ${pref.getString('state_id')??""}");
        print("Share pref ${pref.getString('district_id')??""}");
        print('xyz ${box.read('state_id')}');
        print('abc ${box.read('district_id')}');
      }
    }
  }


}
