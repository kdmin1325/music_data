import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piano_acquisition_application/main.dart';
import 'package:piano_acquisition_application/screen/playListScreen.dart';
import 'package:get/get.dart' as gx;
import '../networkInfo.dart';

class ScoreInfoScreen extends StatefulWidget {
  const ScoreInfoScreen({super.key});

  @override
  State<ScoreInfoScreen> createState() => _ScoreInfoScreenState();
}

class _ScoreInfoScreenState extends State<ScoreInfoScreen> {


  late Future loadScoreData;

  List<Widget> _scoreWidgetList = [];

  String song_name = '';
  String composer = '';
  String duration = '';
  String user_id = '';
  String song_id = '';


  final songInfoController = gx.Get.put(SongInfoController());
  final statusController = gx.Get.put(StatusController());
  @override
  void initState(){
    super.initState();
    song_name = songInfoController.getSongName();
    composer = songInfoController.getComposer();
    duration = songInfoController.getDuration();
    user_id = statusController.getUserId();
    song_id = songInfoController.getSongid();


    loadScoreData = _getScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 40.0,
              child: Text('${song_name}', style: TextStyle(fontSize: 30.0),),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 30.0,
              child: Text('${composer}', style: TextStyle(fontSize: 20.0),),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 30.0,
              child: Text('${duration}', style: TextStyle(fontSize: 20.0),),
            ),
            SizedBox(height: 20.0,),
            Container(
              width: MediaQuery.of(context).size.width,
                child: ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>PlayListScreen()));
                }, child: Text('평가하러 가기', style: TextStyle(fontSize: 15.0, color: Colors.white),)
                ,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)
                      )
                  ),
                )
            ),
            Expanded(
              flex: 1,
              child: Container(
                child: Center(
                  child: Text('데이터 수집을 위한 어플입니다\n 어플 사용 시 음악이 없는 부분이 존재할 수 있습니다.\n 이는 악보가 없는 경우 오류가 아님으로 평가를 진행하시면 됩니다.', style: TextStyle(fontSize: 20.0),),
                ),
              )
            )
          ],
        ),
      ),
    );
  }


  Future<void> _getScores() async{
    Dio dio = Dio();

    try{
      Response res = await dio.get(SERVERIP+'/api/song/getSongScore', queryParameters: {
        'song_id' : song_id
      },
        onReceiveProgress: (val1, val2){
            _scoreWidgetList = [];
        },
      );
      return res.data;

    }catch(e){

    }finally{
      dio.close();
    }

  }
}
