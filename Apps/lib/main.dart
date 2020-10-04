

import 'package:flutter/material.dart';
// import './Screens/description.dart';
// import './widgets/SendAlert.dart';
// import './widgets/contact.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter/services.dart";
import './Screens/auth_screem.dart';
import './providers/auth.dart';
import './Screens/mainscreen.dart';
import "./widgets/Sendcontacts.dart";

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
  bool login = prefs.getBool('login');
  if (login==null)
    login=false;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
   runApp(MyApp(login));
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final bool login;
  MyApp(this.login);
 
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
    providers :[
      ChangeNotifierProvider.value(
        value: Auth(),),
      ],
      child:  Consumer<Auth> (builder: (ctx,auth,_)=> MaterialApp(
        routes: {
          '/sendcontacts':(context)=>SendContacts(),
        },
        initialRoute: '/',
      debugShowCheckedModeBanner: false,
      title: 'Sahayata Project',
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Colors.black
      ),
      home:  (auth.isAuth||login)? MainScreen(auth.token,auth.userId):AuthScreen(),
      ),
    )
    );
  }
}


