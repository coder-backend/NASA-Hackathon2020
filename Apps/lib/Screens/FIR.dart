import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class UserFir{
  final String title;
  final DateTime date;
  final String description;
  final String location;
  final String mailadress;
  final String adharno;
  UserFir({this.date,this.description,this.location,this.mailadress,this.title,this.adharno});
}


class FIR extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:Text("Complains",
        style:TextStyle(
          color:Colors.blue
        )),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: ()=>Navigator.pop(context)),
      ),
      body:FIRlist(),
    );
  }
}

class FIRlist extends StatefulWidget {
  @override
  _FIRlistState createState() => _FIRlistState();
}

class _FIRlistState extends State<FIRlist> {
  static List<UserFir> Fir_list=[];
  

  @override
  Widget build(BuildContext context) {
     return Container(
      height: MediaQuery.of(context).size.height*0.63,
       child: Fir_list.isEmpty
          ?Padding(
            padding: const EdgeInsets.only(top:15.0),
            child: Text("No FIR have been added yet",
            style: TextStyle(
              fontSize: 28
            ),),
          ):
       ListView.builder(
        itemBuilder: (ctx, index){
          return Card(
             elevation: 5,
                  margin: EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 5,
                  ),
                  child:ListTile(
                    title: Text(
                    '${Fir_list[index].title}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20, 
                      color: Colors.black,
                    ), 
                  ),
                  subtitle: Text(Fir_list[index].date.toString())
                  ),
                  );
        }
          )
     );
                
  }
}