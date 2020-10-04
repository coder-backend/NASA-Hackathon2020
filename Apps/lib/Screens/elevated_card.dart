import "package:flutter/material.dart";
class Elevatedcards extends StatelessWidget {
  final   icon;
  final  custom_color;
  final String label;
  Elevatedcards({this.icon,this.custom_color,this.label});
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Container(
      height: deviceSize.height *0.25,
      width:deviceSize.width*0.4,
      child: Card(
        elevation: 5,
        borderOnForeground: true,
        color: Colors.white,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        semanticContainer: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(deviceSize.height*0.03)
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Icon(icon,
              color:custom_color,
              size:deviceSize.height*0.123
              ),
            ),
            Padding(padding: const EdgeInsets.all(3.0),
            child: Text(label,
            style: TextStyle(
              fontSize: deviceSize.height*0.030
            ),),)

          ],
        )    
        ),
    );
  }
}