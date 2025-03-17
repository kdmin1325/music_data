import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as gx;
import '../main.dart';
import '../networkInfo.dart';

class MusicSheetInsertScreen2 extends StatefulWidget {
  const MusicSheetInsertScreen2({super.key});

  @override
  State<MusicSheetInsertScreen2> createState() => _MusicSheetInsertScreen2State();
}

class _MusicSheetInsertScreen2State extends State<MusicSheetInsertScreen2> {
  late String song_name;
  late String composer;
  late String duration;
  late String song_id;
  late String user_id;

  late Future loadPartData;

  final songInfoController = gx.Get.put(SongInfoController());
  final statusController = gx.Get.put(StatusController());



  //Song List Widget
  List<Widget> _scoreWidgetList = [];
  late Future loadScoreFromServer;



  List<File> _files = [];

  // 악보 이미지에 대한 변수 for web
  List<PlatformFile>? _selectedFilesForScore = []; // To store picked files

  List<Widget> imageWidgetList = [];

  @override
  void initState(){
    super.initState();
    song_name = songInfoController.getSongName();
    composer = songInfoController.getComposer();
    duration = songInfoController.getDuration();
    song_id = songInfoController.getSongid();
    user_id = statusController.getUserId();

    loadPartData = _loadSongPartData(int.parse(song_id), user_id);

    loadScoreFromServer =  _getScores();
  }

  List<Widget> _partSongWidget = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder(
        future: loadPartData,
        builder: (context, snapshot){
          if(snapshot.hasData){
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        left: 10.0,
                        right: 10.0
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: 40.0,
                    child: Text('${song_name}', style: TextStyle(fontSize: 30.0),),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 10.0,
                        right: 10.0
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: 30.0,
                    child: Text('${composer}', style: TextStyle(fontSize: 20.0),),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 10.0,
                        right: 10.0
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: 30.0,
                    child: Text('${duration}', style: TextStyle(fontSize: 20.0),),
                  ),
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
          }else{
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('곡 파트 로딩 중입니다.'),
                  SizedBox(width: 5.0,),
                  CircularProgressIndicator(),
                ],
              ),
            );
          }

        },
      ),
    );
  }

  _loadSongPartData(song_id, user_id) async{
    Dio dio = Dio();
    try{
      Response res = await dio.get(SERVERIP+'/api/song/getSongPart', queryParameters: {
        'song_id' : song_id
      });


      List<bool> _checkCompletely = [];

      for(int i=0;i<res.data['part_url_list'].length;i++){
        _checkCompletely.add(false);
      }
      for(int i=0;i< res.data['is_score_list'].length;i++){
        int is_score = res.data['is_score_list'][i];
        if(is_score == 1){
          _checkCompletely[i] = true;
        }
      }
      for(int i=0;i<res.data['part_url_list'].length;i++){
        int sequence = res.data['part_sequence'][i];

        _partSongWidget.add(Container(
          margin: EdgeInsets.only(
              left: 30.0,
              right: 30.0,
              bottom: 5.0
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Colors.grey.shade300,
          ),
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(child: Text('순서: ${sequence}', style: TextStyle(fontSize: 15.0),),padding: EdgeInsets.only(left: 10.0),),
              Container(
                padding: EdgeInsets.all(3.0),
                child: Row(
                  children: [
                    _checkCompletely[i] ? ElevatedButton(onPressed: ()async{

                      dynamic url = await getScoreFromServer(res.data['song_part_id_list'][i].toString());
                      showDialog(context: context, builder: (context){
                        return AlertDialog(
                          content: Container(
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: Image.network(url),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(),
                                      ),
                                      onPressed: (){
                                        showDialog(context: context, builder: (context){
                                          return AlertDialog(
                                            title: Text('정말 삭제하시겠습니까?'),
                                            actions: [
                                              ElevatedButton(onPressed: ()async{

                                                String song_part_id = res.data['song_part_id_list'][i].toString();
                                                await deleteScoreFromServer(song_part_id, song_id.toString());

                                              }, child: Text('네')),
                                          ElevatedButton(onPressed: (){
                                            Navigator.pop(context);
                                          }, child: Text('아니오'))
                                            ],
                                          );
                                        });
                                      },
                                      child: Text('악보 삭제'),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ),
                        );
                      });

                    }, child: Text('악보 확인', style: TextStyle(color: Colors.white),), style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                        ),
                      backgroundColor: Colors.red
                    )):
                    ElevatedButton(onPressed: (){
                      imageWidgetList = [];
                      setState((){});
                      showDialog(context: context, builder: (context){

                        return StatefulBuilder(builder: (context, setState){
                          return AlertDialog(
                            title: Text('악보를 선택해주세요'),
                            content: Container(
                              child: Column(
                                children: [
                                  SingleChildScrollView(
                                    child: Column(
                                      children: imageWidgetList
                                    ),
                                  ),
                                  SizedBox(height: 20.0,),
                                  ElevatedButton(onPressed: (){
                                    imageWidgetList = [];
                                    _selectedFilesForScore = [];
                                    _pickFilesForWEbForScore(setState);

                                  }, child: Text('악보 이미지 선택')),
                                  SizedBox(height: 20.0,),
                                  ElevatedButton(onPressed: () async{
                                    if(_selectedFilesForScore!.isEmpty){
                                      showDialog(context: context, builder: (context){
                                        return AlertDialog(
                                          content: Text('이미지를 선택해세주요'),
                                        );
                                      });
                                    }else{
                                      String? url =  await _uploadFilesForWebForScore();

                                      String song_part_id = res.data['song_part_id_list'][i].toString();
                                      String song_id = this.song_id;
                                      await _sendScoreToServer(song_part_id, song_id, sequence.toString(), url! );

                                    }
                                  }, child: Text('데이터베이스 저장하기'))
                                ],
                              ),
                            ),
                          );
                        });
                      });

                    }, child: Text('악보 넣기', style: TextStyle(color: Colors.black),), style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                      )
                    ),)
                  ],
                ),
              )
            ],
          ),
        ));
      }

      return res.data;
    }catch(e){
    }finally{
      dio.close();
    }
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

  void _pickFilesForWEbForScore(setState) async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Enable multiple selection
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
    );

    if (result != null) {
      setState(() {
        _selectedFilesForScore = result.files;
      });

      for (int i=0; i<_selectedFilesForScore!.length;i++){

        Uint8List? temp = await _selectedFilesForScore?[i].xFile.readAsBytes();

        imageWidgetList.add(
          Image.memory(temp!)
        );

      }
      setState(() {

      });
    }
  }

  Future<String?> _uploadFilesForWebForScore() async {

    Dio _dio = Dio();

    if (_selectedFilesForScore == null || _selectedFilesForScore!.isEmpty) return null;

    FormData formData = FormData();
    for (var file in _selectedFilesForScore!) {
      formData.files.add(MapEntry(
        "files", // Field name for the file
        MultipartFile.fromBytes(file.bytes!, filename: file.name),
      ));
    }

    try {
      var response = await _dio.post(
        SERVERIP+'/api/song/uploadFiles',
        data: formData,
      );
      if (response.statusCode == 200) {
        // Handle response
        return response.data['savepaths'][0];

      }
    } catch (e) {
    }finally{
      _dio.close();
    }
    return null;
  }

  _sendScoreToServer(String song_part_id, String song_id, String sequence, String url) async{
    Dio dio = Dio();



    try{
      // song_id, song_part_id, sequence, url 전송하기.
      Response res = await dio.post(SERVERIP+'/api/song/insertScore',
        data: {
          'song_part_id' : song_part_id,
          'song_id' : song_id,
          'sequence' : sequence,
          'url' : url,
          'song_name' : song_name
        },
        onReceiveProgress: (val1, val2){
          Navigator.pop(context);
          showDialog(context: context, builder: (context){
            return AlertDialog(
              content: Text('저장 완료!'),
            );
          }).then((value) => setState((){
            _partSongWidget = [];
            loadPartData = _loadSongPartData(int.parse(song_id), user_id);
          }));
        }
      );
    }catch(e){
    }finally{
      dio.close();
    }

  }


  getScoreFromServer(String song_part_id)async{

    Dio dio = Dio();

    try{
      Response res = await dio.get(SERVERIP+'/api/song/getSongScore', queryParameters: {
        'song_id' : song_id,
        'song_part_id' :song_part_id
      });


      return res.data['score_url_list'][0];
    }catch(e){

    }finally{
      dio.close();
    }

  }

  deleteScoreFromServer(String song_part_id, String song_id)async{
    Dio dio = Dio();


    try{
      // song_id, song_part_id, sequence, url 전송하기.
      Response res = await dio.post(SERVERIP+'/api/song/deleteScore',
          data: {
            'song_part_id' : song_part_id,
            'song_id' : song_id
          },
          onReceiveProgress: (val1, val2){

          }
      );
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text('악보 삭제 완료!'),
        );
      }).then((value) => setState((){
        Navigator.pop(context);
        Navigator.pop(context);
        _partSongWidget = [];
        loadPartData = _loadSongPartData(int.parse(song_id), user_id);
      }));
    }catch(e){
    }finally{
      dio.close();
    }

  }
}
