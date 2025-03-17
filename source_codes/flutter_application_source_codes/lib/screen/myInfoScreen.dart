import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:piano_acquisition_application/main.dart';
import 'package:piano_acquisition_application/screen/loginScreen.dart';
import 'package:get/get.dart' as gx;
import '../networkInfo.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {

  static final storage = FlutterSecureStorage();

  late Future _loadMyReview;
  late Future _loadMyName;

  List<Widget> _myReviewWidget = [];

  final statusController = gx.Get.put(StatusController());

  late String user_id;
  String user_name = "";
  @override
  void initState(){
    super.initState();
    user_id = statusController.getUserId();

    _loadMyReview = loadReviewData(user_id);
    _loadMyName = loadUserName(user_id);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
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
                height: 60.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(onPressed:_logout, child: Text('로그아웃'),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)
                          )
                      ),
                    ),
                    false ? ElevatedButton(onPressed:(){}, child: Text('내 정보 수정하기'),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)
                          )
                      ),
                    ):Container(),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.white,
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1.0,
                                      color: Colors.black
                                  )
                              ),
                            boxShadow:[
                          BoxShadow(
                          color: Colors.grey.withOpacity(1.0),
                            spreadRadius: 0,
                            blurRadius: 10.0,
                            offset: Offset(0, 10)
                        )
                      ]
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 70.0,
                                  backgroundImage: AssetImage('assets/img/github_main_icon(200x200).png'),
                                ),
                                SizedBox(height: 20.0,),
                                FutureBuilder(future: _loadMyName, builder: (context, snapshot){

                                  if(snapshot.hasData){
                                    return Text('${user_name}', style: TextStyle(fontSize: 30.0),);
                                  }else{
                                    return CircularProgressIndicator();
                                  }
                                })
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  width: MediaQuery.of(context).size.width,
                                  child: Text('내가 평가한 곡 목록', style: TextStyle(fontSize: 20.0),),
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: FutureBuilder(
                                  future: _loadMyReview,
                                  builder: (context, snapshot){
                                    if (snapshot.hasData){
                                      if(snapshot.data['song_name_list'].length == 0){
                                        return Container(
                                          child: Center(
                                            child: Text('평가한 곡이 없습니다!'),
                                          ),
                                        );
                                      }else{
                                        return Container(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: Column(
                                                children: _myReviewWidget
                                            ),
                                          ),
                                        );
                                      }
                                    }else{
                                      return Container(
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text('평가 정보 로딩 중입니다.'),
                                            SizedBox(width: 5.0,),
                                            CircularProgressIndicator(),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              )
                            ],
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
      ),
    );
  }

  void _logout() async{

    await storage.delete(key: 'login');
    await storage.delete(key: 'user_id');
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>LoginScreen()), (route) => false);
  }

  Future<void> loadReviewData(user_id) async{
    Dio dio = Dio();

    try{
      Response res = await dio.get(SERVERIP+'/api/review/getReview', queryParameters: {
        'user_id' : user_id
      });
      for(int i=0;i<res.data['song_name_list'].length;i++){
        String song_name = res.data['song_name_list'][i].toString();
        String duration = res.data['duration_list'][i].toString();
        List<dynamic> sequence = res.data['sequence_list'][i];

        List<dynamic> tone_score_list = res.data['tone_score_list'][i];
        List<dynamic> legato_score_list = res.data['legato_score_list'][i];
        List<dynamic> representation_score_list = res.data['representation_score_list'][i];
        List<dynamic> phrasing_score_list = res.data['phrasing_score_list'][i];
        List<dynamic> melody_score_list = res.data['melody_score_list'][i];
        List<dynamic> music_score_list = res.data['music_score_list'][i];
        List<dynamic> voicing_score_list = res.data['voicing_score_list'][i];
        List<dynamic> note_score_list = res.data['note_score_list'][i];
        List<dynamic> dynamic_score_list = res.data['dynamic_score_list'][i];
        List<dynamic> dynamic_change_score_list = res.data['dynamic_change_score_list'][i];
        List<dynamic> tempo_score_list = res.data['tempo_score_list'][i];
        List<dynamic> tempo_change_score_list = res.data['tempo_change_score_list'][i];
        List<dynamic> articulation_score_list = res.data['articulation_score_list'][i];
        List<dynamic> rhythm_score_list = res.data['rhythm_score_list'][i];
        List<dynamic> pedal_score_list = res.data['pedal_score_list'][i];


        _myReviewWidget.add(Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.all(Radius.circular(10.0))
          ),
          margin: EdgeInsets.only(
              bottom: 10.0,
              left: 10.0,
              right: 10.0
          ),
          padding: EdgeInsets.all(5.0),
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('제목: ${song_name}, 길이: ${duration}초'),
              ElevatedButton(
                  onPressed: (){
                    showDialog(context: context, builder: (context){

                      List<Widget> dialogWidget = [];

                      for(int j =0;j<sequence.length;j++){
                        dialogWidget.add(
                            Container(
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
                                  Container(child: Text('파트: ${sequence[j]}', style: TextStyle(fontSize: 15.0),),padding: EdgeInsets.only(left: 10.0),),
                                  Row(
                                    children: [
                                      IconButton(onPressed: (){

                                        dynamic score1 = tone_score_list[j];
                                        dynamic score2 = legato_score_list[j];
                                        dynamic score3 = representation_score_list[j];
                                        dynamic score4 = phrasing_score_list[j];
                                        dynamic score5 = melody_score_list[j];
                                        dynamic score6 = music_score_list[j];
                                        dynamic score7 = voicing_score_list[j];
                                        dynamic score8 = note_score_list[j];
                                        dynamic score9 = dynamic_score_list[j];
                                        dynamic score10 = dynamic_change_score_list[j];
                                        dynamic score11 = tempo_score_list[j];
                                        dynamic score12 = tempo_change_score_list[j];
                                        dynamic score13 = articulation_score_list[j];
                                        dynamic score14 = rhythm_score_list[j];
                                        dynamic score15 = pedal_score_list[j];


                                        showDialog(context: context, builder: (context){
                                          return AlertDialog(
                                            content: Container(
                                              width: MediaQuery.of(context).size.width/3 *2,
                                              height: MediaQuery.of(context).size.height/3*2,
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Container(
                                                      child: Text('${song_name}, Part: ${sequence[j]}'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 9,
                                                    child: Container(
                                                      child: SingleChildScrollView(
                                                        scrollDirection: Axis.vertical,
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('톤(tone) 점수', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                      borderRadius: BorderRadius.circular(5.0),
                                                                      color: Colors.white
                                                                    ),
                                                                    child: Text('${score1}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('레가토(Legato) 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score2}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('해석(곡의 해석) 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score3}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('프레이징 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score4}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('멜로디 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score5}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('음악성 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score6}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('보이싱(Voicing) 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score7}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('음정 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score8}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('셈여림 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score9}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('셈여림 변화 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score10}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('템포 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score11}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('템포 변화 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score12}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('아티큘레이션(음의 길이 관련) 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score13}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('리듬 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score14}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(5.0),
                                                              margin: EdgeInsets.all(10.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Text('페달링 점수 ', style: TextStyle(fontSize: 16.0),),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                        color: Colors.white
                                                                    ),
                                                                    child: Text('${score15}', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),),
                                                                  )
                                                                ],
                                                              ),
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                  color: Colors.grey.shade300
                                                              ),
                                                              height: 50.0,
                                                            ),


                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        });

                                      }, icon: Icon(Icons.info)),
                                      IconButton(onPressed: (){
                                        showDialog(context: context, builder: (context){
                                          return AlertDialog(
                                            title: Text('정말 삭제하시겠습니까?'),
                                            actions: [
                                              ElevatedButton(onPressed: (){
                                                    deleteReviewData(sequence[0].toString(), song_name, user_id);

                                              }, child: Text('예', style: TextStyle(color: Colors.white),)
                                                ,style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(5.0)
                                                    )
                                                ),
                                              ),
                                              ElevatedButton(onPressed: (){}, child: Text('아니오', style: TextStyle(color: Colors.black),) ,
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(5.0)
                                                    )
                                                ),)
                                            ],
                                          );
                                        });
                                      }, icon: Icon(Icons.cancel)),
                                    ],
                                  )
                                ],
                              ),
                            )
                        );
                      }

                      return AlertDialog(
                        content: Container(
                          width: MediaQuery.of(context).size.width/3*2,
                          height: MediaQuery.of(context).size.height/3*2,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: Center(child: Text('${song_name}'),),
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                      children: dialogWidget
                                  ),
                                ),
                              )
                            ]
                          ),
                        ),
                      );
                    });
                  },
                  child: Text('상세 정보'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                  )
                ),
              ),
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


  Future<void> loadUserName(user_id) async{

    Dio dio = Dio();

    try{
      Response res = await dio.get(SERVERIP+'/api/user/getUserName', queryParameters: {
        'user_id' : user_id
      });

      user_name = res.data['user_name'];

      return res.data;
    }catch(e){

    }finally{
      dio.close();
    }
  }

  Future<void> deleteReviewData(String song_part_id, String song_name, String user_id) async{

    Dio dio = Dio();

    try{
      Response res = await dio.post(SERVERIP+'/api/review/deleteReview',
        data: {
          'user_id' : user_id,
          'song_part_id' : song_part_id,
          'song_name' : song_name
        }
      );
      Navigator.pop(context);
      Navigator.pop(context);
      setState(() {
        _myReviewWidget = [];
        _loadMyReview = loadReviewData(user_id);
      });
      return res.data;

    }catch(e){

    }finally{
      dio.close();
    }
  }

}
