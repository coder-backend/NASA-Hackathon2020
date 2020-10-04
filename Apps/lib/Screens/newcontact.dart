import 'package:flutter/material.dart';
import '../widgets/contact_details.dart';

class NewContact extends StatelessWidget {
  final Function addTx;
  final titleController = TextEditingController();
  final numberController = TextEditingController();

  NewContact(this.addTx);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
              controller: titleController,
              // onChanged: (val) {
              //   titleInput = val;
              // },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Number'),
              controller: numberController,
            ),
            FlatButton(
              child: Text('Add Contact'),
              textColor: Colors.purple,
              onPressed: () {
                 if (titleController.text.isEmpty||numberController.text.isEmpty) {
                      return;}
                      else{
                addTx(
                  titleController.text,
                  numberController.text);
                    
                      }

              },
            ),
          ],
        ),
      ),
    );
  }
}
