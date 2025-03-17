/*
작성 목적: 음악 리뷰 페이지
주요 내용: 음악을 평가하고 각 내용을 리스트 내부에 저장한 뒤 DB로 처리 단계로 넘김
담당자: 김동민
 */

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:piano_acquisition_application/main.dart';
import 'package:piano_acquisition_application/networkInfo.dart';
import 'package:get/get.dart' as gx;
import 'package:piano_acquisition_application/screen/reviewItemScreen.dart';
import 'package:just_audio/just_audio.dart';







class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {

  final player = AudioPlayer();     //다시 듣기를 위한 객체
  final GlobalKey toneKey = GlobalKey();
  final GlobalKey legatoKey = GlobalKey();
  final GlobalKey representationKey = GlobalKey();
  final GlobalKey phrasingKey = GlobalKey();
  final GlobalKey melodyKey = GlobalKey();
  final GlobalKey musicKey = GlobalKey();
  final GlobalKey voicingKey = GlobalKey();
  final GlobalKey noteKey = GlobalKey();
  final GlobalKey dynamicKey = GlobalKey();
  final GlobalKey dynamicChangeKey = GlobalKey();
  final GlobalKey tempoKey = GlobalKey();
  final GlobalKey tempoChangeKey = GlobalKey();
  final GlobalKey articulationKey = GlobalKey();
  final GlobalKey rhythmKey = GlobalKey();
  final GlobalKey pedalKey = GlobalKey();

  final formKey = GlobalKey<FormState>();

  String song_name = 'vetoven';
  String composer = 'vetoven';
  String sequence = '2';
  late String user_id;
  String song_id = '1';

  List<String> reviewList = [
    '톤(tone)',
    '레가토',
    '해석',
    '프레이징',
    '멜로디',
    '음악성, 음악적 표현력',
    '보이싱(voicing)',
    '음정',
    '셈여림',
    '음악의 구조',//셈여림 변화 변경
    '템포',
    '템포의 변화',
    '음의 길이와 관련된 아티큘레이션',
    '리듬',
    '페달링'
  ];

  List<bool> currentReviewItemList = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  List<bool> completeReviewItemList = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];




  int _reviewNum = 0;

  late TextEditingController _scoreController;

  final statusController = gx.Get.put(StatusController());
  final songInfoController = gx.Get.put(SongInfoController());
  final reviewController = gx.Get.put(ReviewController());


  //'톤(tone)',
  //     '레가토',
  //     '해석',
  //     '프레이징',
  //     '멜로디',
  //     '음악성, 음악적 표현력',
  //     '보이싱(voicing)',
  //     '음정',
  //     '셈여림',
  //     '셈여림 변화',
  //     '템포',
  //     '템포의 변화',
  //     '음의 길이와 관련된 아티큘레이션',
  //     '리듬',
  //     '페달링'
  List<int> reviewScoreList = [
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
  ];

  late ScrollController _mainScrollController;


  List<double> widgetWidth = [];
  List<double> widgetPositionList = [];
  @override
  void initState(){
    super.initState();


    _scoreController = TextEditingController();

    user_id = statusController.getUserId();
    song_id = songInfoController.getSongid();
    song_name = songInfoController.getSongName();
    sequence = songInfoController.getSequence();
    composer = songInfoController.getComposer();

    reviewController.setItemName(reviewList.elementAt(_reviewNum));
    checkCurrentReviewItem();

    _mainScrollController = ScrollController();


    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widgetWidth.add(_getSize(toneKey).width);
      widgetWidth.add(_getSize(legatoKey).width);
      widgetWidth.add(_getSize(representationKey).width);
      widgetWidth.add(_getSize(phrasingKey).width);
      widgetWidth.add(_getSize(melodyKey).width);
      widgetWidth.add(_getSize(musicKey).width);
      widgetWidth.add(_getSize(voicingKey).width);
      widgetWidth.add(_getSize(noteKey).width);
      widgetWidth.add(_getSize(dynamicKey).width);
      widgetWidth.add(_getSize(dynamicChangeKey).width);
      widgetWidth.add(_getSize(tempoKey).width);
      widgetWidth.add(_getSize(tempoChangeKey).width);
      widgetWidth.add(_getSize(articulationKey).width);
      widgetWidth.add(_getSize(rhythmKey).width);
      widgetWidth.add(_getSize(pedalKey).width);

      double sum = 0;

      for(int i =0;i<widgetWidth.length;i++){
        widgetPositionList.add(sum);
        sum+=widgetWidth[i];
      }
    });

  }

  @override
  void dispose(){
    super.dispose();

    _scoreController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade300,
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0)
                    )
                  ),
                  child: Row(           // 상단 곡 정보 표시 인터페이스
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('곡 제목 : ${song_name}'),

                      Row(    //다시듣기 인터페이스
                        children: [
                          Text('다시듣기'),
                          IconButton(
                            icon: Icon(Icons.play_arrow),
                            onPressed: () async {
                              String song_url = "https://dalabdgw-platform.s3.amazonaws.com/${composer}/segment_${sequence}.mp3";    // 노래 데이터 호출

                              await player.setUrl(song_url);
                              double volume = 0.5;
                              await player.setVolume(volume);

                              player.pause();     //중복 재생 방지
                              await player.load();  // 음악 호출 부분
                              await player.play();
                            },
                          ),
                        ],
                      ),

                      Text('작곡가 : ${composer}'),
                      Text('Part: ${sequence}'),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                1,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 20.0
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text('평가 목록', style: TextStyle(fontSize: 20.0),),
                      SizedBox(width: 20.0,),
                      Text('평가가 완료된 항목은 초록색으로 표시됩니다.')
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: SingleChildScrollView(
                    controller: _mainScrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        InkWell(
                          key: toneKey,
                          child: Container(
                            child: Text('톤(tone)', style: currentReviewItemList[0] ? TextStyle(color: completeReviewItemList[0]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[0]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[0] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),
                          ),
                          onTap: (){
                            setState(() {
                              _reviewNum = 0;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();

                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10.0,),
                        InkWell(
                          key: legatoKey,
                          child: Container(child: Text('레가토', style: currentReviewItemList[1] ? TextStyle(color: completeReviewItemList[1]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[1]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[1] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),),
                          onTap: (){
                            setState(() {
                              _reviewNum = 1;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10.0,),
                        InkWell(
                          key: representationKey,
                          child: Container(child: Text('해석', style: currentReviewItemList[2] ? TextStyle(color: completeReviewItemList[2]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[2]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[2] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),
                          ),
                          onTap: (){
                            setState(() {
                              _reviewNum = 2;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10.0,),
                        InkWell(
                          key: phrasingKey,
                          child: Container(child: Text('프레이징', style: currentReviewItemList[3] ? TextStyle(color: completeReviewItemList[3]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[3]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[3] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),),
                          onTap: (){
                            setState(() {
                              _reviewNum = 3;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10.0,),
                        InkWell(
                          key: melodyKey,
                          child: Container(child: Text('멜로디', style: currentReviewItemList[4] ? TextStyle(color: completeReviewItemList[4]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[4]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[4] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),),
                          onTap: (){
                            setState(() {
                              _reviewNum = 4;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10.0,),
                        InkWell(
                          key: musicKey,
                          child: Container(child: Text('음악성, 음악적 표현력', style: currentReviewItemList[5] ? TextStyle(color: completeReviewItemList[5]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[5]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[5] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),),
                          onTap: (){
                            setState(() {
                              _reviewNum = 5;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),



                        SizedBox(width: 10.0,),
                        InkWell(
                          key: voicingKey,
                          child: Container(child: Text('보이싱(voicing)', style: currentReviewItemList[6] ? TextStyle(color: completeReviewItemList[6]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[6]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[6] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),),
                          onTap: (){
                            setState(() {
                              _reviewNum = 6;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10.0,),
                        InkWell(
                          key: noteKey,
                          child: Container(child: Text('음정', style: currentReviewItemList[7] ? TextStyle(color: completeReviewItemList[7]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[7]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[7] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),),
                          onTap: (){
                            setState(() {
                              _reviewNum = 7;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10.0),
                        InkWell(
                          key: dynamicKey,
                          child: Container(child: Text('셈여림', style: currentReviewItemList[8] ? TextStyle(color:completeReviewItemList[8]?Colors.green: Colors.blue) :TextStyle(color: completeReviewItemList[8]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[8] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),),
                          onTap: (){
                            setState(() {
                              _reviewNum = 8;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),

                        SizedBox(width: 10.0,),
                        InkWell(
                          key: dynamicChangeKey,
                          child: Container(child: Text('음악의 구조', style: currentReviewItemList[9] ? TextStyle(color: completeReviewItemList[9]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[9]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[9] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),),
                          onTap: (){
                            setState(() {
                              _reviewNum = 9;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),

                        SizedBox(width: 10.0,),
                        InkWell(
                          key: tempoKey,
                          child: Container(child: Text('템포', style: currentReviewItemList[10] ? TextStyle(color: completeReviewItemList[10]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[10]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[10] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),),
                          onTap: (){
                            setState(() {
                              _reviewNum = 10;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),

                        SizedBox(width: 10.0,),
                        InkWell(
                          key: tempoChangeKey,
                          child: Container(child: Text('템포의 변화', style: currentReviewItemList[11] ? TextStyle(color: completeReviewItemList[11]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[11]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[11] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),),
                          onTap: (){
                            setState(() {
                              _reviewNum = 11;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),


                        SizedBox(width: 10.0,),
                        InkWell(
                          key: articulationKey,
                          child: Container(child: Text('음의 길이와 관련된 아티큘레이션', style: currentReviewItemList[12] ? TextStyle(color: completeReviewItemList[12]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[12]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[12] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),),
                          onTap: (){
                            setState(() {
                              _reviewNum = 12;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10.0,),
                        InkWell(
                          key: rhythmKey,
                          child: Container(child: Text('리듬', style: currentReviewItemList[13] ? TextStyle(color: completeReviewItemList[13]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[13]?Colors.green:Colors.black),)
                            ,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[13] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),),
                          onTap: (){
                            setState(() {
                              _reviewNum = 13;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),
                        SizedBox(width: 10.0,),
                        InkWell(
                          key: pedalKey,
                          child: Container(child: Text('페달링', style: currentReviewItemList[14] ? TextStyle(color: completeReviewItemList[14]?Colors.green:Colors.blue) :TextStyle(color: completeReviewItemList[14]?Colors.green:Colors.black),),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(
                                    color: currentReviewItemList[14] ? Colors.blue : Colors.black,
                                    width: 0.5
                                )
                            ),
                            padding: EdgeInsets.all(10.0),),
                          onTap: (){
                            setState(() {
                              _reviewNum = 14;
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 13,
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          renderReviewItemScreen(context),
                          Container(
                            margin: EdgeInsets.only(
                                bottom: 5.0
                            ),
                            width: MediaQuery.of(context).size.width/2,
                            height: 60.0,
                            child: TextFormField(
                              validator: (String? value){
                                if(value?.isEmpty ?? true){
                                  return '점수를 입력해주세요.';
                                }else if(int.parse(value!) >= 0 && int.parse(value) <= 100){
                                  return null;
                                }
                                return '0~100사이 점수만 입력가능합니다.';
                              },
                              controller: _scoreController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: '점수를 입력해주세요!'
                              ),
                            ),
                          ),

                          ElevatedButton(onPressed: (){

                            if(formKey.currentState!.validate()){

                              // 만약 리스트 값 14를 넘어가면 return으로 종료
                              if(_reviewNum > 14){
                                showDialog(context: context, builder: (context){
                                  return AlertDialog(
                                    content: Text('모든 평가 요소 완료 평가 저장하기를 눌러주세요.'),
                                  );
                                });
                                return;
                              }

                              // 현재 평가 요소 리스트에 값 반영
                              reviewScoreList[_reviewNum] = int.parse(_scoreController.text);

                              // 반영 후 점수 제거
                              _scoreController.clear();

                              // 평가한 항목에 대한 bool 리스트 값 할당
                              completeReviewItemList[_reviewNum] = true;


                              // 다음 곡으로 넘어가기
                              _reviewNum+=1;
                              // 만약 리스트값 14가 넘어가면 종료
                              if(_reviewNum > 14){
                                showDialog(context: context, builder: (context){
                                  return AlertDialog(
                                    content: Text('모든 평가 요소 완료 평가 저장하기를 눌러주세요.'),
                                  );
                                });
                                return;
                              }
                              reviewController.setItemName(reviewList.elementAt(_reviewNum));
                              checkCurrentReviewItem();
                              // 만약 리스트값 14가 넘어가면 종료
                              setState(() {

                              });

                              // 평가한 항목에 대해서는 텍스트 필드에 점수가 출력되게 하기
                              if(reviewScoreList[_reviewNum] > 0){
                                setState(() {
                                  _scoreController.text = reviewScoreList[_reviewNum].toString();
                                });
                              }else{
                                _scoreController.clear();
                              }

                              // 다음 평가요소 스크롤 방향 정하기
                              _mainScrollController.animateTo(widgetPositionList[_reviewNum], duration: Duration(milliseconds: 500), curve: Curves.ease);
                            }

                          }, child: Text('저장 및 다음항목', style: TextStyle(color: Colors.white),)
                              ,style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)
                              ),
                              backgroundColor: Colors.red
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey.shade300,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                    bottom: 10.0
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                        )
                    ),
                    onPressed: (){
                      int checkScore = 0;
                      List<int> incompleteIndex = [];
                      for(int i=0;i<reviewScoreList.length;i++){
                        if(reviewScoreList[i] < 0){
                          checkScore += 1;
                          incompleteIndex.add(i);
                        }
                      }
                      List<Widget> _incompleteWidget = [];
                      for(int i=0;i<incompleteIndex.length;i++){
                        _incompleteWidget.add(Text('${reviewList[incompleteIndex[i]]}'));
                      }
                      if(checkScore > 0){
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            title: Text('미완료 평가 요소가 있습니다.'),
                            content: Container(
                              width: MediaQuery.of(context).size.width/2,
                              height: MediaQuery.of(context).size.height/3,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _incompleteWidget,
                                ),
                              ),
                            )
                          );
                        });
                      }else{
                        saveReviewData();
                      }
                    },
                    child: Text('평가 저장하기', style: TextStyle(color: Colors.white),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  saveReviewData() async{

    Dio dio = Dio();

    Map<String, dynamic> new_review_data = {
      'user_id' : user_id,
      'song_id' : song_id,
      'song_part_seq' : sequence,
      'tone_score' : reviewScoreList[0],
      'legato_score': reviewScoreList[1],
      "representation_score" : reviewScoreList[2],
      "phrasing_score": reviewScoreList[3],
          "melody_score": reviewScoreList[4],
          "music_score": reviewScoreList[5],
          "voicing_score": reviewScoreList[6],
          "note_score": reviewScoreList[7],
          "dynamic_score": reviewScoreList[8],
          "dynamic_change_score": reviewScoreList[9],
          "tempo_score": reviewScoreList[10],
          "tempo_change_score": reviewScoreList[11],
          "articulation_score": reviewScoreList[12],
          "rhythm_score": reviewScoreList[13],
          "pedal_score": reviewScoreList[14],
    };

    try{
      Response res = await dio.post(SERVERIP+'/api/review/saveReview',
        data: new_review_data,
        onReceiveProgress: (val1, val2){
          Navigator.pop(context);
        },
        onSendProgress: (val1, val2){
          showDialog(context: context, builder: (context){
            return AlertDialog(
              content: Container(
                width: 70.0,
                height: 50.0,
                child: Text('데이터 저장 중'),
              ),
            );
          });
        }
      );
      Navigator.pop(context);
      Navigator.pop(context);
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Container(
            width: 70.0,
            height: 50.0,
            child: Center(child: Text('데이터 저장 완료', style: TextStyle(fontWeight: FontWeight.bold),),)
          ),
        );
      });
      setState(() {

      });
      return res.data;
    }catch(e){
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Container(
            width: 70.0,
            height: 50.0,
            child: Text('데이터 저장 중 오류 발생'),
          ),
        );
      });
    }finally{
      dio.close();
    }
  }

  void checkCurrentReviewItem(){

    for(int i=0;i<currentReviewItemList.length;i++){
      currentReviewItemList[i] = false;
    }

    if(_reviewNum == 0){
      currentReviewItemList[0] = true;
    }else if(_reviewNum == 1){
      currentReviewItemList[1] = true;
    }else if(_reviewNum == 2){
      currentReviewItemList[2] = true;
    }else if(_reviewNum == 3){
      currentReviewItemList[3] = true;
    }else if(_reviewNum == 4){
      currentReviewItemList[4] = true;
    }else if(_reviewNum == 5){
      currentReviewItemList[5] = true;
    }else if(_reviewNum == 6){
      currentReviewItemList[6] = true;
    }else if(_reviewNum == 7){
      currentReviewItemList[7] = true;
    }else if(_reviewNum == 8){
      currentReviewItemList[8] = true;
    }else if(_reviewNum == 9){
      currentReviewItemList[9] = true;
    }else if(_reviewNum == 10){
      currentReviewItemList[10] = true;
    }else if(_reviewNum == 11){
      currentReviewItemList[11] = true;
    }else if(_reviewNum == 12){
      currentReviewItemList[12] = true;
    }else if(_reviewNum == 13){
      currentReviewItemList[13] = true;
    }else if(_reviewNum == 14){
      currentReviewItemList[14] = true;
    }

  }
  // 위젯 크기 알아오기
  _getSize(GlobalKey key) {
    if (key.currentContext != null) {
      final RenderBox renderBox =
      key.currentContext!.findRenderObject() as RenderBox;
      Size size = renderBox.size;
      return size;
    }
  }
}
