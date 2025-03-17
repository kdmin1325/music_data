import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piano_acquisition_application/networkInfo.dart';
import 'package:piano_acquisition_application/screen/playListScreen.dart';
import 'package:piano_acquisition_application/screen/scoreInfoScreen.dart';
import 'package:get/get.dart' as gx;

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // futures
  late Future loadSongData;

  List<Widget> _songListWidget = [];

  //status management
  final statusController = gx.Get.put(StatusController());
  final songInfoController = gx.Get.put(SongInfoController());

  late String user_id;
  late bool isAdmin; // 어드민 계정 여부를 저장할 변수 추가

  int _currentIndex = 0;

  @override
  void initState(){
    super.initState();
    loadSongData = _loadSongDataFromServer(_currentIndex);
    user_id = statusController.getUserId();
    isAdmin = statusController.getAdmin() == '1'; // 어드민 계정인지 확인
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('음원 평가 시스템', textAlign: TextAlign.center,),
          shape: RoundedRectangleBorder(
              side: BorderSide(
                  width: 0.5,
                  color: Colors.grey
              )
          ),
        ),
        body: FutureBuilder(
          future: loadSongData,
          builder: (context, snapshot){

            if(snapshot.hasData){
              return Container(
                padding: EdgeInsets.only(
                    top: 10.0
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                    children: [
                      Expanded(
                        flex: 8,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: _songListWidget,
                          ),
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: 100.0,
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(onPressed: (){

                                      _currentIndex -= 1;

                                      if(_currentIndex < 0){
                                        _currentIndex = 0;
                                        showDialog(context: context, builder: (context){
                                          return AlertDialog(
                                            title: Text('첫 페이지입니다'),
                                          );
                                        });
                                      }else{
                                        showDialog(context: context, builder: (context){
                                          return AlertDialog(
                                            content: Container(
                                              width: 70.0,
                                              height: 50.0,
                                              child: Row(
                                                children: [
                                                  Text('로딩 중..'),
                                                  CircularProgressIndicator(),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                        setState(() {
                                          loadSongData = _loadSongDataFromServer(_currentIndex);
                                        });
                                        Navigator.pop(context);
                                      }

                                    }, icon: Icon(Icons.keyboard_arrow_left)),
                                    SizedBox(width: 20.0,),
                                    IconButton(onPressed: (){

                                      _currentIndex += 1;
                                      showDialog(context: context, builder: (context){
                                        return AlertDialog(
                                          content: Container(
                                            width: 70.0,
                                            height: 50.0,
                                            child: Row(
                                              children: [
                                                Text('로딩 중..'),
                                                CircularProgressIndicator(),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                      setState(() {
                                        loadSongData = _loadSongDataFromServer(_currentIndex);
                                      });
                                      Navigator.pop(context);

                                    }, icon: Icon(Icons.keyboard_arrow_right)),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50.0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Page ${_currentIndex+1}')
                                  ],
                                ),
                              )
                            ],
                          )
                      )
                    ]
                ),
              );

            } else{
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('곡 로딩 중입니다.'),
                    SizedBox(width: 5.0,),
                    CircularProgressIndicator(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  _loadSongDataFromServer(int page_number) async{

    _songListWidget = [];

    Dio dio = Dio();

    try{
      Response res = await dio.get(SERVERIP+'/api/song/getSongList', queryParameters: {
        'page_number' : page_number,
      },
        onReceiveProgress: (val1, val2){
          _songListWidget = [];
        },
      );

      for(int i=0;i<res.data['song_name_list'].length;i++){
        String song_name = res.data['song_name_list'][i];
        String duration = res.data['duration_list'][i].toString();
        String composer = res.data['composer_list'][i];
        String song_id = res.data['song_id_list'][i].toString();

        _songListWidget.add(Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.all(
                Radius.circular(5.0),
              )
          ),
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          margin: EdgeInsets.only(
              right: 5.0,
              left: 5.0,
              bottom: 5.0
          ),
          padding: EdgeInsets.all(10.0),
          child: Container(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Row(
                      children: [
                        Container(
                          child: SingleChildScrollView(scrollDirection: Axis.horizontal,child: Text('${song_name}')),
                        ),
                        SizedBox(width: 2.0,),
                        if (isAdmin) ...[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                child: SingleChildScrollView(scrollDirection: Axis.horizontal ,child: Text('${composer}', style: TextStyle(fontSize: 10.0),)),
                              ),
                              Container(
                                child: SingleChildScrollView(scrollDirection: Axis.horizontal,child: Text('${duration} 초', style: TextStyle(fontSize: 10.0))),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.only(
                                right: 5.0
                            ),
                            child: ElevatedButton(
                              onPressed: (){
                                final songInfoController = gx.Get.put(SongInfoController());
                                songInfoController.setComposer(composer);
                                songInfoController.setSongId(song_id);
                                songInfoController.setSongName(song_name);
                                songInfoController.setDuration(duration);
                                Navigator.push(context, MaterialPageRoute(builder: (_)=>ScoreInfoScreen()));
                              },
                              child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text('곡 정보', style: TextStyle(fontSize: 10.0, color: Colors.black),)),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)
                                  )
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            child: ElevatedButton(
                              onPressed: (){
                                final songInfoController = gx.Get.put(SongInfoController());
                                songInfoController.setComposer(composer);
                                songInfoController.setSongId(song_id);
                                songInfoController.setSongName(song_name);
                                songInfoController.setDuration(duration);
                                Navigator.push(context, MaterialPageRoute(builder: (_)=>PlayListScreen()));
                              },
                              child: SingleChildScrollView(scrollDirection:Axis.horizontal ,child: Text('평가하기', style: TextStyle(fontSize: 10.0, color: Colors.white), )),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)
                                  )
                              ),
                            ),

                          ),
                        ),

                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
      }

      return res.data;
    }catch(e){
    }finally{
      dio.close();
    }

  }
}
