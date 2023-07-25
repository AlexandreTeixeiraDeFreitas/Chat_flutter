import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipssi2023montevrain/controller/firestore_helper.dart';
import 'package:ipssi2023montevrain/globale.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({super.key});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  //variable
  bool isEditing = false;
  TextEditingController nickName = TextEditingController();

  //méthode
  showCalendar() async {
    DateTime? time = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1970),
        lastDate: DateTime.now(),
    );
    if(time != null){
      setState(() {
        moi.birthday = time;
      });
      Map<String,dynamic> map = {
        "BIRTHDAY":time
      };
      FirestoreHelper().updateUser(moi.uid, map);
    }

  }

  pickerImage() async{
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image
      );
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              //afficher l'image de la personne
              GestureDetector(
                onTap: (){
                  pickerImage();
                },
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: NetworkImage(moi.avatar ?? defaultImage),
                ),
              ),

              const SizedBox(height: 10,),
              
              // nom complet
              Text(moi.fullName,style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),

              GestureDetector(
                onTap: (){
                  showCalendar();
                },
                  child: Text("Age : ${moi.age}",style: const TextStyle(fontSize: 25,fontWeight: FontWeight.bold))),

              const Divider(thickness: 3,color: Colors.black,),
              ListTile(
                leading: Icon(Icons.person),
                title: (isEditing)?TextField(
                  controller: nickName,
                  decoration: InputDecoration.collapsed(

                   hintText: moi.nickName,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    filled: true
                  ),
                ):Text(moi.nickName),
                trailing: IconButton(
                    onPressed: (){
                      if(nickName.text !="" && isEditing == true){
                        Map<String,dynamic> map = {
                          "PSEUDO":nickName.text
                        };

                        FirestoreHelper().updateUser(moi.uid, map);

                      }
                      setState(() {
                        moi.nickName = nickName.text;
                        isEditing = !isEditing;
                      });


                      
                    }, 
                    icon: FaIcon((isEditing)?FontAwesomeIcons.save:FontAwesomeIcons.pencil,size: 20,color: Colors.black,)
                ),
              ),
              ListTile(
                leading: Icon(Icons.mail),
                title: Text(moi.mail),
              ),
              
              //pseudo
              
              //mail
            ],
          ),
        )
    );
  }
}
