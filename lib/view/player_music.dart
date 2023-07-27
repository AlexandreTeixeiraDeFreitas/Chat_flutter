import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ipssi2023montevrain/controller/background_controller.dart';
import 'package:ipssi2023montevrain/globale.dart';
import 'package:ipssi2023montevrain/model/music.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyPlayerMusic extends StatefulWidget {
  List<MyMusic> musicList;
  int initialMusicIndex;

  MyPlayerMusic({required this.musicList, required this.initialMusicIndex, super.key});

  @override
  State<MyPlayerMusic> createState() => _MyPlayerMusicState();
}

class _MyPlayerMusicState extends State<MyPlayerMusic> {
  //variable
  Duration position = Duration(seconds: 0);
  bool isFavorite = false;
  late StatutPlayer statutPlayer;
  late AudioPlayer audioPlayer;
  late double volumeSound;
  late Duration dureeTotalMusic;
  late int currentIndex;


  //méthode

  play(){
    setState(() {
      statutPlayer = StatutPlayer.play;
    });
    audioPlayer.play(UrlSource(widget.musicList[currentIndex].file),volume: volumeSound);
  }

  pause(){
    setState(() {
      statutPlayer = StatutPlayer.pause;
    });
    audioPlayer.pause();
  }

  stop(){
    setState(() {
      statutPlayer = StatutPlayer.stop;
    });
    audioPlayer.stop();
  }

  forward(){
    if(position.inSeconds + 10 <= dureeTotalMusic.inSeconds){
      setState(() {
        Duration time = Duration(seconds: position.inSeconds + 10);
        audioPlayer.seek(time);
      });

    }
    if(position.inSeconds + 10 >= dureeTotalMusic.inSeconds){
      playNextSong();
    }

  }

  backward(){
    if(position.inSeconds <= 10){
      setState(() {
        Duration time = Duration(seconds: 0);
        position = time;
        audioPlayer.seek(time);
        playPreviousSong();
      });

    }
    else
    {
      setState(() {
        Duration time = Duration(seconds: position.inSeconds - 10);
        position = time;
        audioPlayer.seek(time);
      });

    }
  }

  configurationPlayer(){
    statutPlayer = StatutPlayer.stop;
    volumeSound = 0.5;
    dureeTotalMusic = const Duration(seconds: 8000);
    audioPlayer = AudioPlayer();
    audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        dureeTotalMusic = event;
      });
    });
    audioPlayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });
  }

  cleanPlayer(){
    audioPlayer.dispose();
  }

  // Méthode pour jouer la musique suivante
  void playNextSong() {
    setState(() {
      currentIndex = (currentIndex + 1) % widget.musicList.length;
      play();
    });
    checkFavoriteState(); // Check the favorite status after the song changes
  }

  // Méthode pour jouer la musique précédente
  void playPreviousSong() {
    setState(() {
      currentIndex = (currentIndex - 1 + widget.musicList.length) % widget.musicList.length;
      play();
    });
    checkFavoriteState(); // Check the favorite status after the song changes
  }

  @override
  void initState() {
    configurationPlayer();
    currentIndex = widget.initialMusicIndex;
    checkFavoriteState();
    play();
    super.initState();
  }

  void checkFavoriteState() async {
    bool FavoriteState = await moi.isFavorite(widget.musicList[currentIndex].uid);
    setState(() {
      if(FavoriteState){
        isFavorite = true;
      }else{
        isFavorite = false;
      }
    });
  }

  @override
  void dispose() {
    cleanPlayer();
    super.dispose();
  }

  // Future for getting artist info
  Future<Map<String, dynamic>> getArtistInfo(String artistName) async {
    var url = Uri.parse('https://musicbrainz.org/ws/2/artist/?query=artist:"${Uri.encodeComponent(artistName)}"&fmt=json');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      return data['artists'][0];
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.musicList[currentIndex].album ?? ""),
        actions: [
          IconButton(
            onPressed: () async {
              bool currentFavoriteState = await moi.isFavorite(widget.musicList[currentIndex].uid);
              setState(() {
                if (!currentFavoriteState) {
                  isFavorite = true;
                  moi.addToFavorites(widget.musicList[currentIndex].uid);
                } else {
                  isFavorite = false;
                  moi.removeFromFavorites(widget.musicList[currentIndex].uid);
                }
              });
            },
            icon: Icon(Icons.favorite, color: isFavorite ? Colors.red : Colors.white),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MyBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: bodyPage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget bodyPage(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: 250,
            width: 400,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                    image: NetworkImage(widget.musicList[currentIndex].image ?? defaultImage),
                    fit: BoxFit.fill
                )
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: (){
                    volumeSound -= 0.1;
                  },
                  icon: const FaIcon(FontAwesomeIcons.volumeLow)
              ),
              IconButton(
                  onPressed: (){
                    setState(() {
                      volumeSound += 0.1;
                    });
                  },
                  icon: const FaIcon(FontAwesomeIcons.volumeHigh)
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(widget.musicList[currentIndex].title,style: const TextStyle(fontSize: 25),),
                  Text(widget.musicList[currentIndex].artist,style: const TextStyle(fontSize: 20,fontStyle: FontStyle.italic),),
                ],
              ),
              IconButton(
                  onPressed: () async {
                    // Fetch the artist info
                    Map<String, dynamic> artistInfo = await getArtistInfo(widget.musicList[currentIndex].artist);
                    // Display the artist info in an alert dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Informations sur ${widget.musicList[currentIndex].artist}'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nom : ${artistInfo['name']}'),
                              Text('Pays : ${artistInfo['country']}'),
                              Text('Date de début : ${artistInfo['life-span']['begin']}'),
                              Text('Type : ${artistInfo['type']}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              child: Text('Fermer'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.info)
              )

            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timeFormat(position)),
              Text(timeFormat(dureeTotalMusic)),
            ],
          ),
          Slider(
              value: position.inSeconds.toDouble(),
              min: 0,
              max: dureeTotalMusic.inSeconds.toDouble(),
              onChanged: (value){
                setState(() {
                  Duration time = Duration(seconds: value.toInt());
                  position = time;
                  audioPlayer.seek(time);
                });
              }
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: (){
                    playPreviousSong();
                  },
                  icon: const FaIcon(FontAwesomeIcons.backward)
              ),
              IconButton(
                  onPressed: (){
                    backward();
                  },
                  icon: const FaIcon(FontAwesomeIcons.stepBackward)
              ),
              IconButton(
                  onPressed: (){
                    switch(statutPlayer){
                      case StatutPlayer.play:
                        pause();
                        break;
                      case StatutPlayer.stop:
                        play();
                        break;
                      case StatutPlayer.pause:
                        play();
                        break;
                    }
                  },
                  icon: FaIcon(statutPlayer == StatutPlayer.play ? FontAwesomeIcons.pause : FontAwesomeIcons.play)
              ),
              IconButton(
                  onPressed: (){
                    forward();
                  },
                  icon: const FaIcon(FontAwesomeIcons.stepForward)
              ),
              IconButton(
                  onPressed: (){
                    playNextSong();
                  },
                  icon: const FaIcon(FontAwesomeIcons.forward)
              ),
            ],
          ),
        ],
      ),
    );
  }

  String timeFormat(Duration duration){
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    return "${minutes.toString().padLeft(2,'0')}:${seconds.toString().padLeft(2,'0')}";
  }

}

enum StatutPlayer{
  play,
  pause,
  stop,
}
