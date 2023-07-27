import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ipssi2023montevrain/controller/firestore_helper.dart';
import 'package:ipssi2023montevrain/globale.dart';
import 'package:ipssi2023montevrain/model/music.dart';
import 'package:ipssi2023montevrain/view/player_music.dart';

class PageFavori extends StatefulWidget {
  const PageFavori({super.key});

  @override
  _PageFavoriState createState() => _PageFavoriState();
}

class _PageFavoriState extends State<PageFavori> {
  List<MyMusic> userFavorites = [];
  bool loading = true;

  @override
  void initState() {
    loadFavorites();
    super.initState();
  }

  Future<void> loadFavorites() async {
    String userId = "your_user_id"; // replace with your logic to get the user id
    List<String> favoritesIds = await moi.getFavorites();
    for (String id in favoritesIds) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection("MUSIQUES").doc(id).get();
      if (doc.exists) {
        userFavorites.add(MyMusic(doc));
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return ListView.builder(
      itemCount: userFavorites.length,
      itemBuilder: (context, index){
        MyMusic music = userFavorites[index];
        return Card(
          color: Colors.amber,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> MyPlayerMusic(musicList: userFavorites, initialMusicIndex: index)));
            },
            leading: Image.network(music.image ?? defaultImage,width: 100,),
            title: Text(music.title),
            subtitle: Text(music.artist),
          ),
        );
      },
    );
  }
}
