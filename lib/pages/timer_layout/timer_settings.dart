import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mk_kabbani_admin/config.dart';

class TimerSettingsScreen extends StatefulWidget {
  @override
  _TimerSettingsScreenState createState() => _TimerSettingsScreenState();
}

class _TimerSettingsScreenState extends State<TimerSettingsScreen> {

  DateTime selectedDate = DateTime.now();
  String title = '';
  TextEditingController titleCtrl = TextEditingController();
  TextEditingController arTitleCtrl = TextEditingController();

  String arabicTitle = '';
  bool showTimer = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _saveSettings() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference adminSettingsRef =
    firestore.collection('adminSettings').doc('timerSettings');

    await adminSettingsRef.set({
      'timerEndDate': selectedDate,
      'title': title,
      'arabicTitle': arabicTitle,
      'showTimer': showTimer,
    }, SetOptions(merge: true));

    print("Saved timer");
    showDialog(context: context, builder: (context) => AlertDialog(
      title: Text("Timer has been saved successfully",),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      actions: [
        ElevatedButton(onPressed: (){
          Get.back();
        },
            style: ElevatedButton.styleFrom(
              backgroundColor: appCtrl.appTheme.primary,
            ),
            child: Text("OK")),
      ],
    ),);

    // You can display a success message or navigate back to the previous screen
    // depending on your app's design.
  }

  Future<bool> checkIfSettingsExist() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference adminSettingsRef =
    firestore.collection('adminSettings').doc('timerSettings');

    DocumentSnapshot snapshot = await adminSettingsRef.get();
    return snapshot.exists;
  }

  @override
  void initState() {
   checkIfSettingsExist().then((value) async{
     if(value == true){
       FirebaseFirestore firestore = FirebaseFirestore.instance;
       DocumentReference adminSettingsRef =
       firestore.collection('adminSettings').doc('timerSettings');

       DocumentSnapshot snapshot = await adminSettingsRef.get();
       final timerData = snapshot.data() as Map;
       setState(() {
         Timestamp timestamp = timerData['timerEndDate']; // Replace 'timestampField' with your field name
         selectedDate = timestamp.toDate();
         title = timerData['title'];
         titleCtrl.text = timerData['title'];
         arabicTitle = timerData['arabicTitle'];
         arTitleCtrl.text = timerData['arabicTitle'];
         showTimer = timerData['showTimer'];
       });

     }
   });


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Set Timer End Date:',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 8.0),
          Row(
            children: <Widget>[
              Text(
                "${selectedDate.toLocal()}".split(' ')[0],
                style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: 20.0,
              ),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text('Select Date'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appCtrl.appTheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Text(
            'Set Title:',
            style: TextStyle(fontSize: 18.0),
          ),
          TextField(
            onChanged: (value) {
              setState(() {
                title = value;
                titleCtrl.text = value;
              });
            },
            controller: titleCtrl,
            decoration: InputDecoration(
              hintText: 'Enter Title',
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Set Arabic Title:',
            style: TextStyle(fontSize: 18.0),
          ),
          TextField(
            onChanged: (value) {
              setState(() {
                arabicTitle = value;
                arTitleCtrl.text = value;
              });
            },
            controller: arTitleCtrl,
            decoration: InputDecoration(
              hintText: 'Enter Arabic Title',
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Show Timer:',
            style: TextStyle(fontSize: 18.0),
          ),
          Switch(
            value: showTimer,
            activeColor: appCtrl.appTheme.primary,
            onChanged: (newValue) {
              setState(() {
                showTimer = newValue;
              });
            },
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _saveSettings,
            child: Text('Save Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: appCtrl.appTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
