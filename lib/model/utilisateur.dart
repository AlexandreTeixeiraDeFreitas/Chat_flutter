
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ipssi2023montevrain/globale.dart';

import 'music.dart';

class MyUser {
  //attributs
  late String lastName;
  late String firstName;
  late String nickName;
  DateTime? birthday;
  String? avatar;
  late String mail;
  late String uid;
  List? favoris;

  //variable caluclé

  int get age{
    DateTime now = DateTime.now();
    int age = now.year - birthday!.year;
    int month1 = now.month;
    int month2 = birthday!.month;
    if(month2>month1){
      age --;
    }
    else if (month1 == month2) {
      int day1 = now.day;
      int day2 = birthday!.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;


  }

  String get fullName {
    return firstName + " " + lastName ;
  }


  //constructeur
  MyUser(){
    lastName = "";
    firstName = "";
    nickName = "";
    mail = "";
    uid = "";
  }

  MyUser.dataBase(DocumentSnapshot documentSnapshot){
    uid = documentSnapshot.id;
    Map<String,dynamic> map = documentSnapshot.data() as Map<String,dynamic>;
    lastName = map["NOM"];
    nickName = map["PSEUDO"];
    firstName = map["PRENOM"];
    mail = map["EMAIL"];
    Timestamp? timestamp = map["BIRTHDAY"] ;
    if(timestamp == null){
      birthday = DateTime.now();

    }
    else
      {
        birthday = timestamp.toDate();
      }
    avatar = map["AVATAR"] ?? defaultImage;
    favoris = map["FAVORIS"] ?? [];

  }

  Future<bool> isFavorite(String musicId) async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('UTILISATEURS').doc(this.uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      this.favoris = List<String>.from(data['FAVORIS'] ?? []);
      return this.favoris!.contains(musicId);
    } else {
      return false;
    }
  }




  Future<void> addToFavorites(String musicId) async {
    this.favoris!.add(musicId);
    await FirebaseFirestore.instance.collection('UTILISATEURS').doc(this.uid).update({
      'FAVORIS': this.favoris,
    });
  }
  Future<void> removeFromFavorites(String musicId) async {
    this.favoris!.remove(musicId);
    await FirebaseFirestore.instance.collection('UTILISATEURS').doc(this.uid).update({
      'FAVORIS': this.favoris,
    });

  }

  Future<List<String>> getFavorites() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('UTILISATEURS').doc(this.uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      return List<String>.from(data['FAVORIS'] ?? []);
    }
    return [];
  }




//méthodes

}