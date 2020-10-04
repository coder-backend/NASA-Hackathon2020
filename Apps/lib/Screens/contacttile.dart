import 'package:flutter/material.dart';

import "../widgets/contact_details.dart";
import "../Screens/newcontact.dart";
import "../widgets/contact_list.dart";

class Contacttile extends StatefulWidget {
   final List _usercontact;
   Contacttile(this._usercontact);

  @override
  _ContacttileState createState() => _ContacttileState(_usercontact);
}

class _ContacttileState extends State<Contacttile> {
  final List _usercontact;
  _ContacttileState(this._usercontact);
 

  void _addNewContact(String name, String number) {
    final newTx = Contact(
      name: name,
      number: number,
    );
   Contact.addcontacts(newTx);  

    setState(() {
      _usercontact.add(newTx);
    });
  }
  void _deleteTx(String number) {
    Contact.delete(number);
    setState(() {
      _usercontact.removeWhere((tx) => tx.number == number);
    });
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.amberAccent[100],
      appBar: AppBar(
        title:Text("My Contacts"),
        leading: IconButton(icon: Icon(Icons.arrow_back), 
        onPressed:()=> Navigator.of(context).pop()),
      ),
    body: Column(
      children: <Widget>[
        NewContact(_addNewContact),
        Contactlist(_usercontact,_deleteTx),
      ],
    )
    );
  }
}