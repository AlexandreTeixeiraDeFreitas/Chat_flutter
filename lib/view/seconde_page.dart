import 'package:flutter/material.dart';
import 'package:ipssi2023montevrain/controller/all_music.dart';
import 'package:ipssi2023montevrain/controller/background_controller.dart';
import 'package:ipssi2023montevrain/view/my_drawer.dart';

import 'messagerie.dart';
import 'my_page_favori.dart';

class MySecondePage extends StatefulWidget {
  const MySecondePage({Key? key}) : super(key: key);

  @override
  State<MySecondePage> createState() => _MySecondePageState();
}

class _MySecondePageState extends State<MySecondePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width * 0.7,
        decoration: const BoxDecoration(
          color: Colors.amberAccent,
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(85), topRight: Radius.circular(85)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => Messagerie(),
            transitionDuration: Duration(seconds: 1),
            transitionsBuilder: (context, animation, animationTime, child) {
              animation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
              return SlideTransition(
                position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0)).animate(animation),
                child: child,
              );
            },
          ));
        },
        child: const Icon(Icons.message),
        // backgroundColor: TheBaseColors.lightRed,
      ),

    );
  }

  Widget bodyPage(){
    switch(index){
      case 0 : return const Text("Page 1");
      case 1: return const Text("Page 2");
      default : return const Text("Default Page");
    }
  }
}
