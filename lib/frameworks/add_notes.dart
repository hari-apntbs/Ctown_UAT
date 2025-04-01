import 'package:ctown/models/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Home extends StatefulWidget {
  final id;

  const Home({Key? key, this.id}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
   Product? product;
  var _sharedPrefrencesTextValue = new TextEditingController();
  String _savedData = "";
  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  _loadSavedData() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? savedNotes ;
    setState(() {
      if(sharedPreferences.getString(widget.id) != null && sharedPreferences.getString(widget.id)!.isNotEmpty){
        // _sharedPrefrencesTextValue.text = sharedPreferences.getString(widget.id);
        savedNotes=sharedPreferences.getString(widget.id);
      }
    });
    return savedNotes;
  }

  _saveData(String message) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(widget.id, message);
    setState(() {
      _savedData=message;
    });

  }

  @override
  Widget build(BuildContext context) {
    return 

     Container(
        padding: const EdgeInsets.all(13.4),
        alignment: Alignment.topCenter,
        child:
        FutureBuilder(
          future: _loadSavedData(),
          builder: (context, AsyncSnapshot snapshot){
if(snapshot.hasData){
  return ListTile(
          title: new TextField(
            controller: _sharedPrefrencesTextValue,
            // maxLines: 4,
            decoration: new InputDecoration(labelText: 'Write Something',
            suffixIcon: InkWell(
              onTap: (){     _saveData(_sharedPrefrencesTextValue.text);},
              child: Icon(Icons.send))
            ),
          ),
          subtitle:  new Column(
                children: <Widget>[
                  // new Text('Save Data'),
                  new Padding(padding: new EdgeInsets.all(14.5)),
                  new Text(snapshot.data),
                ],
              )
        );
}return  new ListTile(
          title: new TextField(
            controller: _sharedPrefrencesTextValue,
            decoration: new InputDecoration(labelText: 'Write Something',
             suffixIcon: InkWell(
              onTap: (){     _saveData(_sharedPrefrencesTextValue.text);},
              child: Icon(Icons.send))
            ),
          ),
          subtitle:  Column(
                children: <Widget>[
                  // new Text('Save Data'),
                  new Padding(padding: new EdgeInsets.all(14.5)),
                  new Text(_savedData),
                ],
              )
        );
          },
        )
        
      

    );
  }
}