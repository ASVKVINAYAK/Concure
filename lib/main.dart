import 'dart:async';
import 'package:covid19_tracker/model/CenterList.dart';
import 'package:covid19_tracker/screens/home_screen.dart';
import 'package:covid19_tracker/services/networking.dart';
import 'package:http/http.dart' as http;
import 'package:covid19_tracker/model/config.dart';
import 'package:covid19_tracker/screens/dashboard.dart';
import 'package:covid19_tracker/screens/slot_booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import "package:hive_flutter/hive_flutter.dart";
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher()
{
  Workmanager.executeTask((taskName, inputData) async {
    print("bg");
    if(taskName=="vaccine_notify") {
      print("fetch");
      NotificationService nr = new NotificationService();
      GetStorage box = GetStorage('MyStorage');
      Networking n=new Networking();
      n.get_notified();
      SharedPreferences pref = await SharedPreferences.getInstance();
      String now = DateFormat("dd-MM-yyyy").format(DateTime.now());
      String p=pref.getString('pincode')??"check";
      String d=now;
      print("bg check");
         // if(p=="check")
         //   {
         //     print("if pincode=${p}&date=${d}");
         //     nr.show();
         //   }
         // else
         //   {
         //     print("else pincode=${p}&date=${d}");
         //     availbypincode(p, d);
         //     print("not open ");
         //   }
      availbypincode(p, d);
      nr.notify_alert();
      // n.get_notified();
      //checkAvailability2();
      return Future.value(true);
    }
    return Future.value(true);
  });
}


void main() async {

  await Hive.initFlutter();
  await GetStorage.init('MyStorage');
  box = await Hive.openBox('easyTheme');
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager.initialize(callbackDispatcher);
  await Workmanager.registerPeriodicTask("vaccine_notify", "vaccine_notify",
      inputData: {"data1": "value1", "data2": "value2"},
      frequency: Duration(minutes: 1),
      initialDelay: Duration(minutes: 1));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  _MyApp createState() => _MyApp();
}
availbypincode(String p, String d) async {
  print("checlkavailability bg pincode=${p}&date=${d}");
  NotificationService nr = new NotificationService();
  var u = Uri.parse(
      'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=${p}&date=${d}');
  var response = await http.get(u);
  print("res ${response.statusCode}");
    var centerList = await http
        .get(u)
        .then((value) => CenterList.fromJson(value.body));
    for (var e in centerList.centers) {
      print('Center pincode bg : ${e.name}');
      var avail = e.sessions
          .map((el) => el.availableCapacity>0)
          .toList()
          .toSet()
          .toList();
      if (avail.contains(true))
        // get notification
          {
        List<SessionDetails> sessions = e.sessions
            .map((e) => e.availableCapacity>0 ? e : null)
            .toList()
          ..removeWhere((el) => el == null);
        for (var session in sessions)
        {
          print("Center bg ${e.name}");
          nr.showvaccine(e.name, session.date, session.availableCapacity.toString());
        }
      }
    }

}
// Future<void> checkAvailability() async {
//   GetStorage box = GetStorage();
//   var currentDistrictId = box.read('district_Id');
//   if (currentDistrictId != null) {
//     DateTime currentdate = DateTime.now();
//     for (var i = 0; i < 14; i++) {
//       DateTime date = currentdate.add(Duration(days: i));
//       String dateString = '${date.day}-${date.month}-${date.year}';
//       final _url =
//       // 'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=453&date=20-05-2021';
//           'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=$currentDistrictId&date=$dateString';
//       // print(_url);
//       var centerList = await http
//           .get(Uri.parse(_url))
//           .then((value) => CenterList.fromJson(value.body));
//       bool isAvailable = false;
//       for (var e in centerList.centers) {
//         // print('Center: ${e.name}');
//         var avail = e.sessions
//             .map((el) => el.minAgeLimit > 0)
//             .toList()
//             .toSet()
//             .toList();
//         if (avail.contains(true)) ifAvailable(e);
//         if (avail.contains(true)) isAvailable = true;
//       }
//       if (isAvailable) break;
//     }
//     print('bg-fetch complete............................................');
//   }
// }
// void ifAvailable(CenterDetails e) {
//   print('Vaccine Available in your district Go Book soon! on Date: ${e.name}');
//   NotificationService n= new NotificationService();
//   List<SessionDetails> sessions = e.sessions
//       .map((e) => e.minAgeLimit > 0 ? e : null)
//       .toList()
//     ..removeWhere((el) => el == null);
//   String p="";
//   String d="";
//   for (var session in sessions)
//     {
//        p="";
//        d="";
//        p+="${e.pincode}";
//        d=d+"${session.availableCapacity}";
//        n.show(p,d);
//     }
//
// }

// Future<bool> checkAvailability2() async {
//   GetStorage box = GetStorage();
//   Networking n=new Networking();
//   n.get_notified();
//   bool isAvailable = false;
//   print("check2");
//   var currentDistrictId = box.read('district_id');
//   if (currentDistrictId != null) {
//     String dateString = DateFormat("dd-MM-yyyy").format(DateTime.now());
//     final _url =
//         'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=$currentDistrictId&date=$dateString';
//     // print(_url);
//     var response = await http.get(_url);
//     // print("res ${response.body}");
//     if (response.statusCode == 200) {
//       var r = covidvaccinebypinFromJson(response.body);
//       List<Centers> s = r.centers;
//       List<Session> ct;
//       bool av=false;
//       NotificationService nr= new NotificationService();
//       for(int i=0;i<s.length;++i)
//         {
//           print("vinayak");
//            ct=s[i].sessions;
//            for(int j=0;j<ct.length;++j)
//              {
//                print("${ct[j].minAgeLimit}");
//                nr.ifAvailable(s[i],ct[j]);
//              }
//         }
//
//     }
//   }
//   return isAvailable;
// }

class _MyApp extends State<MyApp> {
 // Timer _timerForInter;
  @override
  void initState() {
    super.initState();
    // _timerForInter = Timer.periodic(Duration(seconds: 60), (result) {
    //   Networking n = new Networking();
    //   n.get_notified();
    //   print("abc");
    //   NotificationService r=new  NotificationService();
    //   r.show();
    //   print("demo");
    //   checkAvailability2();
    // });
    currentTheme.addListener(() {
      print("Changed");
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
 return MultiProvider(
    child:
        MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Concure',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.grey,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: currentTheme.currentTheme(),
          home: HomeScreen(),
      //home: DashboardScreen(),
        ),
     providers: [
       ChangeNotifierProvider(create: (_) => NotificationService())
    ]);
  }
}


class NotificationService extends ChangeNotifier{
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  Future initialize() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings("splash");

    IOSInitializationSettings iosInitializationSettings =
    IOSInitializationSettings();

    final InitializationSettings initializationSettings =
    InitializationSettings(android:androidInitializationSettings,iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification);
  }

  Future<void> ifAvailable(Centers center,Session sesion) async {
    print('Vaccine Available in: ${center.pincode}');
    var android = AndroidNotificationDetails("1687497218170948721x8", "New Trips Notification", "Notification Channel for vendor. All the new trips notifications will arrive here.",importance: Importance.max,priority: Priority.high,
        showWhen: false);
    var ios = IOSNotificationDetails();
    var platform = new NotificationDetails(android:android,iOS:ios);
    await _flutterLocalNotificationsPlugin.show(0, "Vaccine Available at ${center.pincode}", "Totat Vaccine availabe ${sesion.availableCapacity} \n Book now for ${sesion.minAgeLimit} \n On ${sesion.date}", platform);
  }
  // Future shownotification() async {
  //   var interval = RepeatInterval.everyMinute;
  //   var android = AndroidNotificationDetails("1687497218170948721x8", "New Trips Notification", "Notification Channel for vendor. All the new trips notifications will arrive here.",importance: Importance.max,priority: Priority.high,
  //     showWhen: false);
  //
  //   var ios = IOSNotificationDetails();
  //
  //   var platform = new NotificationDetails(android:android,iOS:ios);
  //
  //   await _flutterLocalNotificationsPlugin.periodicallyShow(
  //       5,"xya","abc",interval ,platform,
  //       payload: "Welcome to demo app");
  //   // await _flutterLocalNotificationsPlugin.periodicallyShow(
  //   //     5,"xyz","abc",show(),interval ,platform,
  //   //     payload: "Welcome to demo app");
  // }
  Future onSelectNotification(String payload) {

  }

  Future<void> show()
  async {
    var android = AndroidNotificationDetails("1687497218170948721x8", "New Trips Notification", "Notification Channel for vendor. All the new trips notifications will arrive here.",importance: Importance.max,priority: Priority.high,
        showWhen: false);

    var ios = IOSNotificationDetails();

    var platform = new NotificationDetails(android:android,iOS:ios);

    await _flutterLocalNotificationsPlugin.show(0, "Notify me for vaccine availability ", "Enter pincdoe for more details ", platform);
  }
  Future<void> showvaccine(String name, String date,String details)
  async {
    var android = AndroidNotificationDetails("1687497218170948721x8", "New Trips Notification", "Notification Channel for vendor. All the new trips notifications will arrive here.",importance: Importance.max,priority: Priority.high,
        showWhen: false);

    var ios = IOSNotificationDetails();

    var platform = new NotificationDetails(android:android,iOS:ios);

    await _flutterLocalNotificationsPlugin.show(0, "Vaccine Available at ${name} on ${date}", "Total doses available ${details}", platform);
  }
  Future<void> notify_alert()
  async{
    GetStorage box = GetStorage('MyStorage');
    Networking n=new Networking();
    n.get_notified();
    SharedPreferences pref = await SharedPreferences.getInstance();
    String now = DateFormat("dd-MM-yyyy").format(DateTime.now());
    String p=pref.getString('pincode')??"check";
    String d=pref.getString('date')??now;
    //check pincode available
    print("checlkavailability bg pincode=${p}&date=${d}");
    var u = Uri.parse(
        'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByPin?pincode=${p}&date=${d}');
    var response = await http.get(u);
    print("res ${response.statusCode}");
    var centerList = await http
        .get(u)
        .then((value) => CenterList.fromJson(value.body));
    for (var e in centerList.centers) {
      print('Center pincode bg : ${e.name}');
      var avail = e.sessions
          .map((el) => el.availableCapacity>0)
          .toList()
          .toSet()
          .toList();
      if (avail.contains(true))
        // get notification
          {
        List<SessionDetails> sessions = e.sessions
            .map((e) => e.availableCapacity>0 ? e : null)
            .toList()
          ..removeWhere((el) => el == null);
        for (var session in sessions)
        {
          print("Center bg ${e.name}");
          showvaccine(e.name, session.date, session.availableCapacity.toString());
        }
      }
    }
  //  checkavailabilty1(p,d);
    print("notify alert");
    //get nearby by centers
    String di=pref.getString('district_id')??null;
    var currentDistrictId = di;
    print("cd id ${currentDistrictId}");
    if (currentDistrictId != null) {
      DateTime currentdate = DateTime.now();
      for (var i = 0; i < 14; i++) {
        DateTime date = currentdate.add(Duration(days: i));
        String dateString = '${date.day}-${date.month}-${date.year}';
        print("date ${dateString}");
        final _url =
        // 'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=453&date=20-05-2021';
            'https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/calendarByDistrict?district_id=$currentDistrictId&date=$dateString';
        // print(_url);
        var centerList = await http
            .get(_url)
            .then((value) => CenterList.fromJson(value.body));
        bool isAvailable = false;
        for (var e in centerList.centers) {
          print('Center: ${e.name}');
          var avail = e.sessions
              .map((el) => el.availableCapacity>0)
              .toList()
              .toSet()
              .toList();
          if (avail.contains(true))
           // get notification
            {
            List<SessionDetails> sessions = e.sessions
                .map((e) => e.availableCapacity>0 ? e : null)
                .toList()
              ..removeWhere((el) => el == null);
            for (var session in sessions)
            {
              print("notification ${session.minAgeLimit}");
              var android = AndroidNotificationDetails("1687497218170948721x8", "New Trips Notification", "Notification Channel for vendor. All the new trips notifications will arrive here.",importance: Importance.max,priority: Priority.high,
                  showWhen: false);
              var ios = IOSNotificationDetails();
              var platform = new NotificationDetails(android:android,iOS:ios);
              await _flutterLocalNotificationsPlugin.show(0, "Vaccine Available at ${e.pincode} on ${session.date}", "Total Vaccine availabe ${session.availableCapacity} \n Book now ", platform);
            }
            }
          if (avail.contains(true)) isAvailable = true;
        }
        if (isAvailable) break;
      }
      print('bg-fetch complete............................................');
    }
  }
}


