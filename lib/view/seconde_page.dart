import 'package:flutter/material.dart';
import 'package:ipssi2023montevrain/controller/all_music.dart';
import 'package:ipssi2023montevrain/controller/background_controller.dart';
import 'package:ipssi2023montevrain/view/my_drawer.dart';

import 'my_page_favori.dart';

class MySecondePage extends StatefulWidget {
  const MySecondePage({super.key});

  @override
  State<MySecondePage> createState() => _MySecondePageState();
}

class _MySecondePageState extends State<MySecondePage> {
  //variables
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(
        height: MediaQuery.of(context).size.height ,
        width: MediaQuery.of(context).size.width * 0.7,

        decoration: const BoxDecoration(
            color: Colors.amberAccent,
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(85),topRight: Radius.circular(85))
        ),
        child: const MyDrawer(),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const MyBackground(),
          SafeArea(
              child: bodyPage()
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value){
          setState(() {
            index= value;
          });

        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
            label: "Musique"
          ),

          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Favoris"
          ),

        ],
      ),
    );
  }

  Widget bodyPage(){
    switch(index){
      case 0 : return const Text("coucou");
      case 1: return Text("coucou");
      default : return Text("coucou");
    }

  }
}
