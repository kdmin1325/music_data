/*
작성 목적: 음악을 재생하기 위해 작성된 페이지
주요 내용: api 서버에서 음악을 호출한 뒤 재생 시킴, _PlayListScreenState 클래스를 이용한 작동
담당자: 김동민
 */
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:piano_acquisition_application/main.dart';
import 'package:piano_acquisition_application/screen/reviewScreen.dart';
import 'package:get/get.dart' as gx;
import '../networkInfo.dart';

class PlayListScreen extends StatefulWidget {
  const PlayListScreen({super.key});

  @override
  State<PlayListScreen> createState() => _PlayListScreenState();
}

class _PlayListScreenState extends State<PlayListScreen> {
  late String song_name;
  late String composer;
  late String duration;
  late String song_id;
  late String user_id;
  late String sequence;
  late bool isAdmin; // 어드민 계정 여부를 저장할 변수 추가

  late Future loadPartData;

  final songInfoController = gx.Get.put(SongInfoController());
  final statusController = gx.Get.put(StatusController());

  // Song List Widget
  List<Widget> _scoreWidgetList = [];
  late Future loadScoreFromServer;

  @override
  void initState() {
    super.initState();
    song_name = songInfoController.getSongName();
    composer = songInfoController.getComposer();
    duration = songInfoController.getDuration();
    song_id = songInfoController.getSongid();
    user_id = statusController.getUserId();
    sequence = songInfoController.getSequence();
    isAdmin = statusController.getAdmin() == '1'; // 어드민 계정인지 확인

    loadPartData = _loadSongPartData(int.parse(song_id), user_id);
  }

  List<Widget> _partSongWidget = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: loadPartData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    width: MediaQuery.of(context).size.width,
                    height: 40.0,
                    child: Text(
                      '${song_name}',
                      style: TextStyle(fontSize: 30.0),
                    ),
                  ),
                  if (isAdmin) ...[
                    Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      width: MediaQuery.of(context).size.width,
                      height: 30.0,
                      child: Text(
                        '${composer}',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      width: MediaQuery.of(context).size.width,
                      height: 30.0,
                      child: Text(
                        '${duration}',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ],
                  Divider(),
                  Expanded(
                    flex: 1,
                    child: Container(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: _partSongWidget,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('곡 파트 로딩 중입니다.'),
                  SizedBox(width: 5.0),
                  CircularProgressIndicator(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  _loadSongPartData(song_id, user_id) async {
    Dio dio = Dio();
    AudioPlayer player = AudioPlayer(); // 재생을 위한 객체 생성

    try {
      Response res = await dio.get(SERVERIP + '/api/song/getSongPart', queryParameters: {
        'song_id': song_id
      });

      Response res2 = await dio.get(SERVERIP + '/api/review/getReviewDataByUserIdSongId', queryParameters: {
        'user_id': user_id,
        'song_id': song_id
      });

      List<bool> _checkCompletely = [];

      for (int i = 0; i < res.data['part_url_list'].length; i++) {
        _checkCompletely.add(false);
      }
      for (int i = 0; i < res2.data['sequence_list'].length; i++) {
        _checkCompletely[res2.data['sequence_list'][i]] = true;
      }

      for (int i = 0; i < res.data['part_url_list'].length; i++) {

        print(res.data['part_url_list']);

        int sequence = res.data['part_sequence'][i];

        // 평가 완료 된 경우 배경색 지정하는 코드
        Color col = _checkCompletely[i] ? Colors.blueGrey.shade300 : Colors.grey.shade300;

        _partSongWidget.add(Container(
          margin: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: col,
          ),
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text(
                  '순서: ${sequence}',
                  style: TextStyle(fontSize: 15.0),
                ),
                padding: EdgeInsets.only(left: 10.0),
                color: col,
              ),
              Row(
                children: [
                  _checkCompletely[i] ? Text('완료', style: TextStyle(color: Colors.green)) : Text('평가필요'),
                  SizedBox(width: 5.0),
                  IconButton(
                    onPressed: () async {
                      songInfoController.setSequence(sequence.toString());

                      String song_url = res.data['part_url_list'][i]; // url 불러오기 작업

                      player.pause(); // 중복 재생 방지
                      await player.setUrl(song_url); // 노래 경로 설정
                      double volume = 0.5;
                      await player.setVolume(volume);

                      bool isScore = false;

                      String url = await _getScores(res.data['song_part_id_list'][i].toString());
                      if (url == ' ') {
                        isScore = false;
                      } else {
                        isScore = true;
                      }
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('${sequence}번째 곡 입니다. 곡에 집중해주세요!'),
                            content: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: isScore
                                        ? Container(
                                      child: Image.network(url),
                                    )
                                        : Container(
                                      child: Text('악보가 없습니다.'),
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 100.0,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: Row(
                                            children: [
                                              IconButton(
                                                onPressed: () async {
                                                  await player.load(); // 음악 호출 부분
                                                  Stopwatch stopwatch = new Stopwatch();
                                                  stopwatch.start();
                                                  await player.play();
                                                  print('doSomething() executed in ${stopwatch.elapsed}');
                                                  print(song_url);
                                                  stopwatch.stop();
                                                },
                                                icon: Icon(Icons.play_circle),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  player.pause();
                                                },
                                                icon: Icon(Icons.stop),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return ReviewScreen();
                                                },
                                              );
                                            },
                                            child: Text('평가지'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.play_arrow),
                  ),
                ],
              )
            ],
          ),
        ));
      }

      return res.data;
    } catch (e) {
      // handle exception
    } finally {
      dio.close();
    }
  }

  Future<dynamic> _getScores(String song_part_id) async {
    Dio dio = Dio();

    try {
      String song_Sequence = songInfoController.getSequence();

      Response res = await dio.get(
        SERVERIP + '/api/song/getSongScore',
        queryParameters: {
          'song_id': song_name,
          'song_part_id': song_Sequence,
          'sequence': song_Sequence, // 상태 관리에서 가져온 sequence 사용
          'song_name': song_name
        },
      );

      return res.data['score_url_list'][0];
    } catch (e) {
      print("오류 발생: $e");
      return ' ';
    } finally {
      dio.close();
    }
  }

}
