import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:piano_acquisition_application/networkInfo.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ScoreInsertScreen extends StatefulWidget {
  const ScoreInsertScreen({super.key});

  @override
  State<ScoreInsertScreen> createState() => _ScoreInsertScreenState();
}

class _ScoreInsertScreenState extends State<ScoreInsertScreen> {


  // controllers
  late TextEditingController _songNameController; // 곡 이름 텍스트 필드 컨트롤러
  late TextEditingController _authorNameController; // 작곡가 이름 텍스트 필드 컨트롤러
  late TextEditingController _durationController; // 곡 길이 텍스트 필드 컨트롤러

  // 곡 파일에 대한 변수
  bool _isPickFile = false;
  String _pickFileName = '';
  String _pickFilePath = '';

  // 악보 이미지에 대한 변수
  String song_id = '0';
  List<File> _files = [];
  final Dio _dio = Dio();


  // 곡 파일에 대한 변수 for web
  List<PlatformFile>? _selectedFilesForSong = []; // To store picked files

  // 악보 이미지에 대한 변수 for web
  List<PlatformFile>? _selectedFilesForScore = []; // To store picked files



  // 악보 이미지 출력을 위한 위젯
  List<Widget> _scoreImageWidgetList = [];
  @override
  void initState(){
    super.initState();
    _songNameController = TextEditingController();
    _authorNameController = TextEditingController();
    _durationController = TextEditingController();


  }

  @override
  void dispose(){
    super.dispose();
    _songNameController.dispose();
    _authorNameController.dispose();
    _durationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              child: Text('곡 입력기', style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),),
            ),
            Divider(),
            Expanded(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 80.0,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                child: TextField(
                                  controller: _songNameController,
                                  decoration: InputDecoration(
                                    hintText: '곡 제목을 입력하세요.',
                                    border: OutlineInputBorder()
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 80.0,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                child: TextField(
                                  controller: _authorNameController,
                                  decoration: InputDecoration(
                                      hintText: '버전을 입력하세요.',
                                      border: OutlineInputBorder()
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 80.0,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                child: TextField(
                                  controller: _durationController,
                                  decoration: InputDecoration(
                                      hintText: '곡의 길이를 입력하세요.',
                                      border: OutlineInputBorder()
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(20.0)
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: 120.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              kIsWeb ? Text(_selectedFilesForSong!.isEmpty ?  '선택한 곡 파일이 없습니다.' : '선택한 곡 파일명\n${_selectedFilesForSong![0].name}', style: TextStyle(fontSize: 20.0, color: Colors.white, overflow: TextOverflow.ellipsis),textAlign: TextAlign.center,) :Text(_isPickFile ?  '선택한 곡 파일명\n${_pickFileName}' : '선택한 곡 파일이 없습니다.', style: TextStyle(fontSize: 20.0, color: Colors.white, overflow: TextOverflow.ellipsis),textAlign: TextAlign.center,),
                            ],
                          )
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                child: ElevatedButton(
                                  onPressed: kIsWeb ?_pickFilesForWEbForSong :_pickFile,
                                  child: Text('음원 파일 선택하기 (mp3)', style: TextStyle(color: Colors.white),),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)
                                    )
                                  ),
                                )
                              ),
                            )
                          ],
                        ),
                      ),
                      /*
                      Container(
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(20.0)
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: 120.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _files.isEmpty && _selectedFilesForScore!.isEmpty ? Text('선택한 악보 파일이 없습니다.', style: TextStyle(fontSize: 20.0, color: Colors.white, overflow: TextOverflow.ellipsis),textAlign: TextAlign.center,)
                              : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _scoreImageWidgetList
                                ),
                              )
                            ],
                          )
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                  child: ElevatedButton(
                                    onPressed: kIsWeb? _pickFilesForWEbForScore :_pickFiles,
                                    child: Text('악보 파일 선택하기 (png)', style: TextStyle(color: Colors.white),),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0)
                                        )
                                    ),
                                  )
                              ),
                            )
                          ],
                        ),
                      ),
                       */
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        margin: EdgeInsets.only(
                          top: 30.0
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                  child: ElevatedButton(
                                    onPressed: ()async{
                                      await sendToServerSongInfo();
                                    },
                                    child: Text('저장하기', style: TextStyle(color: Colors.white),),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0)
                                        )
                                    ),
                                  )
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,

      ),
    );
  }


  // 곡 정보 -> 서버 통신 API
  sendToServerSongInfo()async{
    Dio dio = Dio();

    String songName = _songNameController.text;
    String author = _authorNameController.text;
    int duration = int.parse(_durationController.text);

    String upload_path = '';
    try{
      if (kIsWeb){
        List<dynamic>? upload_data = await _uploadFilesForWebForSong();
        upload_path = upload_data?[0];
      }else{
        Map<String, dynamic> upload_data =  await uploadFile(_pickFilePath);
        upload_path = upload_data['savepath'];
      }

      dynamic data = {
        'songName' : songName,
        'composer' : author,
        'duration' : duration,
        'upload_path' : upload_path
      };
      Response res2 = await dio.post(SERVERIP+'/api/song/insertSong', data: data
        , onSendProgress: (val1, val2){
            showDialog(context: context, builder: (context){
              return AlertDialog(
                content: Container(
                  width: 200.0,
                  height: 80.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('데이터베이스에 곡정보 반영중..', style: TextStyle(fontSize: 20.0),),
                      SizedBox(height: 10.0,),
                      CircularProgressIndicator()
                    ],
                  )
                ),
              );
            });
          },
        onReceiveProgress: (val1, val2){
          Navigator.pop(context);
        }
      );
      if(res2.statusCode == 200){
        song_id = res2.data['song_id'].toString();
      }
    }catch(e){
      showDialog(context: context,barrierDismissible: false, builder: (context){

        return AlertDialog(

          content: Container(
            width: 200.0,
            height: 100.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('곡 정보 저장 중 오류 발생', style: TextStyle(fontSize: 20.0),),
                ElevatedButton(onPressed: (){
                  Navigator.pop(context);
                  _songNameController.clear();
                  _authorNameController.clear();
                  _durationController.clear();
                  _isPickFile = false;
                  setState(() {

                  });
                }, child: Text('확인'))
              ],
            ),
          ),
        );
      });
    }finally{
      dio.close();
    }

  }
  // 악보 정보 -> 서버 통신 API
  sendToServerScoreInfo() async{
    Dio dio = Dio();

    String songName = _songNameController.text;

    try{
      List<dynamic>? uploadPathList = kIsWeb ? await _uploadFilesForWebForScore() : await _uploadFiles();

      dynamic data = {
        'song_name' : songName,
        'song_id' : song_id,
        'score_path_list' : uploadPathList
      };
      Response res2 = await dio.post(SERVERIP+'/api/song/insertScore', data: data
          , onSendProgress: (val1, val2){
            showDialog(context: context, builder: (context){
              return AlertDialog(
                content: Container(
                    width: 200.0,
                    height: 80.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('데이터베이스에 악보 정보 반영중..', style: TextStyle(fontSize: 20.0),),
                        SizedBox(height: 10.0,),
                        CircularProgressIndicator()
                      ],
                    )
                ),
              );
            });
          },
          onReceiveProgress: (val1, val2){
            Navigator.pop(context);
            showDialog(context: context,barrierDismissible: false, builder: (context){

              return AlertDialog(

                content: Container(
                  width: 200.0,
                  height: 100.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('저장 완료', style: TextStyle(fontSize: 20.0),),
                      ElevatedButton(onPressed: (){
                        Navigator.pop(context);
                        _songNameController.clear();
                        _authorNameController.clear();
                        _durationController.clear();
                        _isPickFile = false;
                        setState(() {

                        });
                      }, child: Text('확인'))
                    ],
                  ),
                ),
              );
            });
          }
      );


    }catch(e){
      showDialog(context: context, builder: (context){
        return AlertDialog(
          title: Text('악보 저장 중 오류 발생'),
        );
      });
    }finally{
      dio.close();
    }


    _files = []; // 이미지를 저장하는 객체
    _songNameController.clear();
    _authorNameController.clear();
    _durationController.clear();
  }



  /*
  ==============================================================
  ==============================================================
  ==============================================================
  하단 부 파일 선택 기능 정의
   */

  // 곡 삽입 for Mobile
  _pickFile() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [
        'mp3',
        'wav',
        'mp4'
      ]
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        _isPickFile = true;
        _pickFileName = file.name;
      });

      // 파일을 서버에 업로드
      if (file.path != null) {
        _pickFilePath = file.path!;
      }
    } else {
      // 사용자가 파일 선택을 취소한 경우
    }
  }
  Future<Map<String, dynamic>> uploadFile(String filePath) async {
    var dio = Dio();
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: _pickFileName),
      });
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Container(
            width: 200.0,
            height: 60.0,
            child: Column(
              children: [
                Text('곡 업로드 중입니다.', style: TextStyle(fontSize: 20.0),),
              ],
            ),
          ),
        );
      });
      var response = await dio.post(
          SERVERIP+'/api/song/upload', data: formData,

        onReceiveProgress: (val1, val2){
            Navigator.pop(context);
        }
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }finally{
      dio.close();
    }
  }

  // 악보 삽입 for Mobile
  void _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'jpg',
        'png'
      ]
    );

    if (result != null) {
      setState(() {
        _files = result.paths.map((path) => File(path!)).toList();
        
      });
      for (int i=0; i<_files.length;i++){
        
        Uint8List temp = await _files[i].readAsBytes();
        
        _scoreImageWidgetList.add(
            InkWell(
              child: Container(
                margin: EdgeInsets.only(
                  left: 5.0
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.all(10.0),
                width: 100.0,
                height: 100.0,
                child: Image.memory(temp),
              ),
              onTap: (){
                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    content: Container(
                      child: Image.memory(temp),
                    ),
                  );
                });
              },
            )
        );
      }
      setState(() {
        
      });
    }
  }
  Future<List<dynamic>?> _uploadFiles() async {
    var formData = FormData();

    for (File file in _files) {
      formData.files.add(MapEntry(
        "files",
        MultipartFile.fromFileSync(file.path, filename: file.path.split('/').last),
      ));
    }


    try {
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Container(
              width: 200.0,
              height: 80.0,
              child: Row(
                children: [
                  Text('악보 전송 중..'),
                  SizedBox(height: 5.0),
                  CircularProgressIndicator()
                ],
              )
          ),
        );
      });
      var response = await _dio.post(
        SERVERIP+'/api/song/uploadFiles',
        data: formData,
        onReceiveProgress: (val1, val2){
          Navigator.pop(context);
        }
      );
      if (response.statusCode == 200) {
        return response.data['savepaths'];
      } else {
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: Container(
                width: 200.0,
                height: 80.0,
                child: Row(
                  children: [
                    Text('악보 전송 실패'),
                  ],
                )
            ),
          );
        });
        return null;
      }
    } catch (e) {
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Container(
              width: 200.0,
              height: 80.0,
              child: Row(
                children: [
                  Text('악보 전송 실패'),
                ],
              )
          ),
        );
      });
    }
    return null;
  }

  /*/ for Web
  ===========================================
   */

  /* */
  void _pickFilesForWEbForSong() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false, // Enable multiple selection
      type: FileType.custom,
      allowedExtensions: ['mp3', 'mp4'],
    );

    if (result != null) {
      setState(() {
        _selectedFilesForSong = result.files;
      });
      setState(() {

      });
    }
  }
  void _pickFilesForWEbForScore() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Enable multiple selection
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
    );

    if (result != null) {
      setState(() {
        _selectedFilesForScore = result.files;
      });

      for (int i=0; i<_selectedFilesForScore!.length;i++){

        Uint8List? temp = await _selectedFilesForScore?[i].xFile.readAsBytes();

        _scoreImageWidgetList.add(
            InkWell(
              child: Container(
                margin: const EdgeInsets.only(
                    left: 5.0
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: EdgeInsets.all(10.0),
                width: 100.0,
                height: 100.0,
                child: Image.memory(temp!),
              ),
              onTap: (){
                showDialog(context: context, builder: (context){
                  return AlertDialog(
                    content: Container(
                      child: Image.memory(temp),
                    ),
                  );
                });
              },
            )
        );
      }
      setState(() {

      });
    }
  }
  // Function to upload selected files
  Future<List<dynamic>?> _uploadFilesForWebForScore() async {
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
        return response.data['savepaths'];
      }
    } catch (e) {
    }
    return null;
  }
  Future<List<dynamic>?> _uploadFilesForWebForSong() async {
    if (_selectedFilesForSong == null || _selectedFilesForSong!.isEmpty) return null;

    FormData formData = FormData();
    for (var file in _selectedFilesForSong!) {
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
        return response.data['savepaths'];
      }
    } catch (e) {
    }
    return null;
  }
}
