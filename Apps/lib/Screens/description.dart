import "package:flutter/material.dart";

class Description extends StatelessWidget {
  final myController = TextEditingController();
  final String type;
  Description(this.type);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("Descriptions")
      ),
      body:Column(
        children: <Widget>[
          Text("Type : $type",
          style:TextStyle(
            fontSize: 20,
            color: Colors.black
          )),
          Flexible(
            fit: FlexFit.tight,
            flex: 2,
          child:TextField(
            controller: myController,
          )
          ),
          FlatButton(onPressed: ()
          {}
          ,
           child: Text("Send request"))
        ],
      )
      
    );
  }
}