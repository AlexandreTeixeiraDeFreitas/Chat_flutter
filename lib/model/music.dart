
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ipssi2023montevrain/globale.dart';

class MyMusic {
  late String uid;
  late String title;
  late String artist;
  late String file;
  String? image;
  String? album;



  MyMusic(DocumentSnapshot snapshot){
    uid = snapshot.id;
    Map<String,dynamic> map = snapshot.data() as Map<String,dynamic>;
    title = map["TITLE"];
    artist = map["ARTIST"];
    file = map["FILE"];
    album = map["ALBUM"] ?? "";
    image = map["IMAGE"] ?? defaultImage;

  }
  MyMusic.build({required this.title,this.image,required this.artist,required this.uid,this.album,required this.file});

}