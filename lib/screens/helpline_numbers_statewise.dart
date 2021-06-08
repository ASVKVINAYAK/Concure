import 'package:covid19_tracker/screens/Indian.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class HelpLine extends StatefulWidget {
  @override
  _Helpline createState() => new _Helpline();
}

class _Helpline extends State<HelpLine> {
  TextEditingController _numberCtrl = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 2;
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Indian()));
              },
            ),
          ],
          title: Text(
            'Concure',
          ),
          centerTitle: true,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Container(
                      height: MediaQuery.of(context).size.height-50,
                      color: Colors.blue[50],
                      child: Expanded(
                        child: ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: [
                            Tile("Andhra Pradesh ", "08662410978"),
                            Tile("Arunachal Pradesh ", "09436055743"),
                            Tile("Assam ", "06913347770"),
                            Tile("Bihar ", "104"),
                            Tile("Chhattisgarh ", "104"),
                            Tile("Goa ", "104"),
                            Tile("Gujarat", "104"),
                            Tile("Haryana", "8558893911"),
                            Tile("Himachal Pradesh", "104"),
                            Tile("Jharkhand", "104"),
                            Tile("Karnataka", "104"),
                            Tile("Kerela", "04712552056"),
                            Tile("Madhya Pradesh", "104"),
                            Tile("Maharashtra", "02026127394"),
                            Tile("Manipur", "3852411668"),
                            Tile("Meghalaya", "108"),
                            Tile("Mizoram", "102"),
                            Tile("Nagaland", "7005539653"),
                            Tile("Odisha", "9439994859"),
                            Tile("Punjab", "104"),
                            Tile("Rajsthan", "01412225624"),
                            Tile("Sikkim", "104"),
                            Tile("Tamil Nadu ", "04429510500"),
                            Tile("Telangana", "104"),
                            Tile("Tripura", "03812315879"),
                            Tile("Uttarakhand", "104"),
                            Tile("Uttar Pradesh", "18001805145"),
                            Tile("West Bengal", "1800313444222"),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Union Territory ",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Tile("Andaman and Nicobar Islands ", "03192232102"),
                            Tile("Chandigarh ", "9779558282"),
                            Tile(" Dadra and Nagar Haveli and\n Daman &  Diu ",
                                "104"),
                            Tile("Delhi ", "01122307145"),
                            Tile("Jammu and Kashmir ", "01912520982"),
                            Tile("Ladakh ", "01982256462"),
                            Tile("Lakshadweep ", "104"),
                            Tile("Puducherry ", "104"),
                          ],
                        ),
                      ),
                    ),
                  ),
              ),
        ),
      ),
    );
  }

  Widget Tile(String title, String contact) {
    return Column(children: [
      ListTile(
        title: Text(
          title + " Helpline number",
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        trailing: GestureDetector(
            onTap: () async {
              // const number = contact;  //set the number here
              bool res = await FlutterPhoneDirectCaller.callNumber(contact);
            },
            child: Icon(
              Icons.call,
              color: Colors.green.withOpacity(1),
            )),
        selected: true,
        selectedTileColor: Colors.white,
      ),
    ]);
  }
}
