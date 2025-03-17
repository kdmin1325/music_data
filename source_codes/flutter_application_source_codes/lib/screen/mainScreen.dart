import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:piano_acquisition_application/screen/homeScreen.dart';
import 'package:piano_acquisition_application/screen/musicSheetInsertScreen.dart';
import 'package:piano_acquisition_application/screen/scoreInsertScreen.dart';
import 'package:piano_acquisition_application/screen/searchScreen.dart';
import '../main.dart';
import 'myInfoScreen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {



  String user_id = '';

  int _selectedIndex = 0 ;
  String admin = '1'; // admin인지? 0 = 일반 사용자 , 1 = 관리자
  bool screenadmin = false;
  List<Widget> _screenList = [

  ];


  @override
  void initState(){
    super.initState();
    final statusController = Get.put(StatusController());
    admin = statusController.getAdmin();
    if(admin == '0'){
      screenadmin = true;
    }else if(admin == '1'){
      screenadmin = false;
    }else{
      screenadmin = true;
    }
    _screenList = screenadmin ? [
      HomeScreen(),
    SearchScreen(),
    MyInfoScreen(),
    ] : [
      HomeScreen(),
      SearchScreen(),
      MusicSheetInsertScreen(),
      ScoreInsertScreen(),
      MyInfoScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: _screenList.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          items: screenadmin ? [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
          ] :[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
            BottomNavigationBarItem(icon: Icon(Icons.library_music_rounded), label: '악보 넣기'),
            BottomNavigationBarItem(icon: Icon(Icons.music_note), label: '곡 넣기'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
          ] ,
          onTap: (value){
            setState(() {
              _selectedIndex = value;
            });
          },
        ),
      ),
    );
  }
}
