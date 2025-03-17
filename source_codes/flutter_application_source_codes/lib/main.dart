import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piano_acquisition_application/screen/loginScreen.dart';
import 'package:piano_acquisition_application/screen/reviewItemScreen.dart';
import 'package:piano_acquisition_application/screen/reviewScreen.dart';
import 'package:piano_acquisition_application/screen/scoreInfoScreen.dart';


void main() {
  runApp(
    GetMaterialApp(
      title: '음원 평가 시스템',
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    )
  );
}


class StatusController extends GetxController{
  String user_id = "";
  String admin = "";

  void setUserId(String userId){
    this.user_id = userId;
  }

  void setAdmin(String admin){
    this.admin = admin;
  }

  String getUserId(){
    return this.user_id;
  }

  String getAdmin(){
    return this.admin;
  }
}

class SongInfoController extends GetxController{

  String sequence = '0';
  String song_name = '';
  String composer = '';
  String song_id = '';
  String duration = '';


  void setInfo(song_name, sequence, composer, song_id){
    this.sequence = sequence;
    this.song_name = song_name;
    this.composer = composer;
    this.song_id = song_id;
  }

  void setSongName(String song_name){
    this.song_name = song_name;
  }

  void setSequence(String sequence){
    this.sequence = sequence;
  }

  void setComposer(String composer){
    this.composer = composer;
  }

  void setSongId(String song_id){
    this.song_id = song_id;
  }

  void setDuration(String duration){
    this.duration = duration;
  }

  String getSequence(){
    return this.sequence;
  }

  String getComposer(){
    return this.composer;
  }

  String getSongid(){
    return this.song_id;
  }

  String getSongName(){
    return this.song_name;
  }

  String getDuration(){
    return this.duration;
  }
}

class ReviewController extends GetxController{

  String itemName = "톤(tone)";

  void setItemName(String itemName){
    this.itemName = itemName;
  }
  String getItemName(){
    return this.itemName;
  }
}
