

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:provider/provider.dart';
import 'package:sms/sms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import "../Screens/contacttile.dart";
import "../widgets/SendAlert.dart";
import "../widgets/Panicbutton.dart";
import '../widgets/contact_details.dart';
import "./elevated_card.dart";
import "./routes.dart";
import "../main.dart";

class MainScreen extends StatefulWidget {

  final String  tokenno;
  final String userid;
  MainScreen(this.tokenno,this.userid);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FirebaseMessaging _messaging=FirebaseMessaging();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState(){
    final String serverToken = '***********************';
    super.initState();
    _messaging.getToken().then((token){
       _switchbutton(token);
    });
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if(message["notification"]["title"]=="Confirmation"){
          print("yeta badhnu parne ho k reh");
        alertState.setState(() { alertState.pcounter+=1;});
        return;
        }
              var location = new Location();
LocationData currentLocation = await location.getLocation();
        print(message);
        double user_lat=double.parse(message["data"]["latitude"]);
        double user_long=double.parse(message["data"]["longitude"]);
        print(user_lat);
        print(user_long);
        String name=message["data"]["name"];
        String description=message["data"]["Description"];
        String phone_number=message["data"]["phone_no"];
        print(phone_number);
        print(name);
        print(description);

  Widget cancelButton = RaisedButton(
    color: Colors.white,
    child: Text("No"),
    onPressed:  () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = RaisedButton(
    color:Colors.red,
    child: Text("Navigate me"),
    onPressed:  ()async {
        var result=await http.post(
    'https://fcm.googleapis.com/fcm/send',
     headers: <String, String>{
       'Content-Type': 'application/json',
       'Authorization': 'key=$serverToken',
     },
     body: jsonEncode(
     <String, dynamic>{
       'registration_ids': [message["data"]["return_token"]],
       'notification': <String, dynamic>{
         'title': 'Confirmation',
         'body':'',
       },
       
     },
    ),
  );
   var outcome=jsonDecode(result.body);
  print(outcome);
  Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(builder: (_){
        return Routes(long: user_long,lat: user_lat,currentLocation: currentLocation,ph:phone_number);
      }));

    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Help Alert"),
    content: Text("$name need your help.\nDescription:$description.\n Do you wish to help?"),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

new Future.delayed(Duration.zero, (){ showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
});

      },
      onLaunch: (Map<String, dynamic> message) async {
                if(message["notification"]["title"]=="confirmation"){
        alertState.setState(() { alertState.pcounter+=1;});
        return;
        }


                      var location = new Location();
LocationData currentLocation = await location.getLocation();
         double user_lat=double.parse(message["data"]["latitude"]);
        double user_long=double.parse(message["data"]["longitude"]);
        String phone_number=message["data"]["phone_no"];

        var result=await http.post(
    'https://fcm.googleapis.com/fcm/send',
     headers: <String, String>{
       'Content-Type': 'application/json',
       'Authorization': 'key=$serverToken',
     },
     body: jsonEncode(
     <String, dynamic>{
       'registration_ids': [message["data"]["return_token"]],
       'notification': <String, dynamic>{
         'title': 'Confirmation',
         'body':'',
       },
     },
    ),
  );
  print(result.body);
        Navigator.of(context).push(MaterialPageRoute(builder: (_){
        return Routes(long: user_long,lat: user_lat,currentLocation: currentLocation,ph:phone_number);
      }));
      },

       onResume: (Map<String, dynamic> message) async {
                               var location = new Location();
LocationData currentLocation = await location.getLocation();
         double user_lat=double.parse(message["data"]["latitude"]);
        double user_long=double.parse(message["data"]["longitude"]);
        String phone_number=message["data"]["phone_no"];
                var result=await http.post(
    'https://fcm.googleapis.com/fcm/send',
     headers: <String, String>{
       'Content-Type': 'application/json',
       'Authorization': 'key=$serverToken',
     },
     body: jsonEncode(
     <String, dynamic>{
       'registration_ids': [message["data"]["return_token"]],
       'notification': <String, dynamic>{
         'title': 'Confirmation',
         'body':'',
       },
     },
    ),
  );
  print(result.body);
      

            Navigator.of(context).push(MaterialPageRoute(builder: (_){
        return Routes(long: user_long,lat: user_lat,currentLocation: currentLocation,ph:phone_number);
      }));
      },
      );
  }


Future<FirebaseUser> getFirebaseUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if(user==null)
    {
      final FirebaseAuth _auth = FirebaseAuth.instance;
      SharedPreferences prefs = await SharedPreferences.getInstance();
       String email = prefs.getString('email');
       String password=prefs.getString('password');
      _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user2 = await FirebaseAuth.instance.currentUser();
      print(user2);
      return user2;
    }
    else
    return user;
}

    _database(context,{forcontacts=false}) async {
    LocationData currentLocation;
   final  firestore=Firestore.instance;

    var location = new Location();
    try {
      currentLocation = await location.getLocation();

      double lat = currentLocation.latitude;
      double lng = currentLocation.longitude;
      final coordinates = new Coordinates(lat, lng);
      if (forcontacts)
      {
        return coordinates;
      }
      var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    } catch (e) {
      print("error");
      print(e);
    }
  }

  Future<void> callstring(context,String text,String type,{String alternalte})
  async{
    Coordinates corde= await _database(context,forcontacts: true);
    double lat=corde.latitude;
    double long=corde.longitude;
    final String url='https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$long&rankby=distance&type=$type&keyword=$text&key=*******';
    print(url);
    var response = await http.get(url, headers: {"Accept": "application/json"});
    print(response.body);
    List data=json.decode(response.body)["results"];
    String phone_no=null;
    if (data!=[]){
      print(data);
    String place_id=data[0]["place_id"];
      final String detailUrl =
      "https://maps.googleapis.com/maps/api/place/details/json?placeid=$place_id&fields=name,formatted_phone_number&key=******************";
      var response2 = await http.get(detailUrl, headers: {"Accept": "application/json"});
      print("-------Second Part------");
      print(response2.body);
      var result=json.decode(response2.body)["result"]; 
      if(result!=null)
      {
      print(result);
       phone_no=result["formatted_phone_number"];
       print(result["name"]);
      print(phone_no);
      if(phone_no==null)
      {
        phone_no=alternalte;
      }
      }
      else{
        phone_no=alternalte;
      }
    }
    else
    phone_no=alternalte;      
      print("So far working");
      launch("tel:$phone_no");
      print("working??");
  }

  void backgroundFetchHeadlessTask(String taskId) async {
  print('[BackgroundFetch] Headless event received.');
  BackgroundFetch.finish(taskId);
}

Future<bool> _switchbutton(String fcm_tokens) async {
     BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: true,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
    ), (String taskId) async {
      Coordinates corde= await _database(context,forcontacts: true);
      print("data sent");
      var firestore=Firestore.instance;
       FirebaseUser user=await getFirebaseUser();
       print(user);
      var token= await user.getIdToken(refresh: true);
     String token_id =token.token;
     String fcm_token=fcm_tokens;
       
      print("here is the token");
      print(token_id);
      firestore.collection('markers').document(user.uid).setData({'Location':new GeoPoint(corde.latitude, corde.longitude),
        'Token':token_id,
        "fcm_token":fcm_token,
      });
        
      print("working");
    });
     SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('Sendloc', true); 
      bool loc=prefs.getBool('Sendloc');
      return loc;        
  }

  _contactsend(context) async{
   List contactList=await Contact.getdatabase();
    print("so far so good");
    print(contactList);
    print(contactList.length);
    if (contactList.length==0)
    {
      return showDialog<void>(
      context:context ,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No contacts'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text("You don't have any contacts please add some contacts and come back")],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ); 
    }

    

  else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  String name=prefs.getString("name");
    Coordinates cord= await _database(context,forcontacts: true);
    double lat=cord.latitude;
    double long=cord.longitude;
     String message = "$name is in trouble, find him in:http://maps.google.com/?q=$lat,$long";
     print(message);
     _sendSMS(message,contactList,context);

  }
  }

  void _sendSMS(String send_message,  List<Contact> recipents,context) async {
  SmsSender sender = new SmsSender();
 for (int i=0;i<recipents.length;i++)
 {
   String address=recipents[i].number;
   String name=recipents[i].name;
  SmsMessage message = new SmsMessage(address, send_message);
  message.onStateChanged.listen((state) {
    if (state == SmsMessageState.Sent) {
    } else if (state == SmsMessageState.Delivered) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("SMS is delivered to $name"),
          duration: Duration(seconds: 5),
        )
        );
    }
    else if(state==SmsMessageState.Fail)
    {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Failed sending SMS to $name"),
          duration: Duration(seconds: 5),
      action: SnackBarAction(label: "Resend",
      textColor: Colors.blue,
       onPressed: (){
        SmsMessage message = new SmsMessage(address, send_message);
      }),
         )
      );
    }
  });
  sender.sendSms(message);
 }
}

  @override
  Widget build(BuildContext context) {
     final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
         title: Text("Make a SOS request",
         style:TextStyle(
           fontWeight:FontWeight.w600,
           fontSize: 24,
         )
         ),
         actions: <Widget>[
           IconButton(icon: Icon(Icons.group_add), 
           onPressed: () async {
             List contactList=await Contact.getdatabase();
             Navigator.of(context).push(MaterialPageRoute(builder: (_){
               return Contacttile(contactList);
             }));
           }
           )
         ],      
      ),
     body: SingleChildScrollView(
       child:Container(
         height:MediaQuery.of(context).size.height*0.9, 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height*0.5,
                child: GridView.count(crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: <Widget>[
                  InkWell(
                    splashColor: Colors.amber,
                    autofocus: true,
                    onDoubleTap: (){
                      callstring(context, "fire brigade","",alternalte: "102");
                    },
                  child:Elevatedcards(icon: Icons.whatshot,custom_color: Colors.amberAccent,label: "Fire",),),
                  InkWell(
                    splashColor: Colors.lightBlue,
                    autofocus: true,
                    onDoubleTap: (){
                      callstring(context, "Police Station","police",alternalte: "100");
                    },
                  child:Elevatedcards(icon:Icons.face,custom_color:Colors.lightBlue,label:"Police"),),
                   InkWell(
                     splashColor: Colors.redAccent,
                    autofocus: true,
                    onDoubleTap: (){
                      callstring(context, "Hospital","hospital",alternalte: "911");
                    },
                  child:Elevatedcards(icon:Icons.local_hospital,custom_color:Colors.red,label:"Hospital")),
                   InkWell(
                     splashColor: Colors.amberAccent[100],
                    autofocus: true,
                    onDoubleTap: (){callstring(context, "Gurudwara","",alternalte: "911");},
                  child:Elevatedcards(icon:Icons.home,custom_color:Colors.orange,label:"Shelter")),      
                ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  InkWell(
                   autofocus: true,
                   onDoubleTap:()async{
                     await _database(context);
                     Coordinates corde= await _database(context,forcontacts: true);
                     Navigator.of(context).push(MaterialPageRoute(builder: (_){
               return SendAert(corde);
             })
             );
                     }, 
                    child:PanicButton(helptext: "SOS",backgroundColor: Colors.red,health: true,)
                  ),
                  InkWell(
                    autofocus: true,
                    onDoubleTap:()async{
                      _contactsend(context);
                      Navigator.pushNamed(context, '/sendcontacts',arguments:"health");},
                    child:PanicButton(helptext: " Contacts",
                    backgroundColor: Colors.red,health:false
                  )
                  ) 
                ]
              ),
               Padding(
                 padding: const EdgeInsets.only(top:20.0),
                 child: ButtonTheme(
                   minWidth: 150,
                   height: 80,
                  child:
                   RaisedButton(onPressed: ()async{
                     SharedPreferences prefs = await SharedPreferences.getInstance();
                     prefs.setBool("login", false);
                      final FirebaseAuth _auth = FirebaseAuth.instance;
                      _auth.signOut();
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_){
                 return MyApp(false);
                    }
                    )
                    );
                  },
                    padding: EdgeInsets.all(10),
                    autofocus: true,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius:  BorderRadius.circular(10),
                    ),
                      color: Colors.white,
                      child: Text("Sign out",
                      style: TextStyle(
                        color:Colors.blue,
                        fontSize:20
                      ),)
                      ),
                 ),
               ),        
            ]
          )
        ) 
     )
     );       
  }
}
