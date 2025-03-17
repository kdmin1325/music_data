import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:piano_acquisition_application/main.dart';
import 'package:get/get.dart' as gx;


renderReviewItemScreen(context){
  String itemName = '해석';//톤(tone)

  final reviewController = gx.Get.put(ReviewController());

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
    '음악의 구조',
    '템포',
    '템포의 변화',
    '음의 길이와 관련된 아티큘레이션',
    '리듬',
    '페달링'
  ];

  List<Map<String, List<String>>> reviewDescriptionList = [
    {'톤(tone)' : ['소리의 질이 좋은지', '톤이 잘 정리 됬는지', '톤 balance가 잘 유지 되는지', '음색이 좋은지', '소리가 아름다운지']},
    {'레가토' : ['레가토가 잘 되는지?']},
    {'해석' : ['해석의 적절성', '스토리 텔링이 잘되는지', '해석에 확신이 느껴지는지']},
    {'프레이징' : ['프레이징이 잘 나타나는지', '프레이징이 긴지 짧은지']},
    {'멜로디' : ['멜로디의 자유로움', '오른손 멜로디의 표현력', '루바토를 잘하는지']},
    {'음악성, 음악적 표현력' : ['음악성', '음악적 표현력', '음악적 표현력에 확신이 느껴지는지', '음악이 flat한지']},
    {'보이싱(voicing)' : ['오른손과 왼손 소리 크기의 비율', '멜로디가 잘 들리는지', '반주가 너무 크지는 않은지']},
    {'음정' : ['정확한 음정으로 연주하는지']},
    {'셈여림' : ['정확한 셈여림으로 연주하는지']},
    {'음악의 구조' : ['음악의 구조를 전체적으로 얼마나 잘 표현했는가']},
    {'템포' : ['정확한 속도로 연주하는지']},
    {'템포의 변화' : ['템포의 변화가 이루어지는 시점에서 자연스럽게 템포가 변화되는지']},
    {'음의 길이와 관련된 아티큘레이션' : ['읨의 길이, 붙임줄, 스타카토, 테누토, 늘임표', '아티큘레이션을 잘지켜서 연주하는지']},
    {'음의 세기와 관련된 아티큘레이션' : ['악센트', '아티큘레이션을 잘 지켜서 연주하는지']},
    {'리듬' : ['리드미컬하게 잘 연주하는지', '리듬이 느껴지는지']},
    {'페달링' : ['정확하게 페달링을 하는지','페달리 깔끔한지']},
  ];
  List<Widget> reviewDescriptionWidget = [];

  itemName = reviewController.getItemName();
  for(int i=0;i<reviewDescriptionList.length;i++){
    if(reviewDescriptionList[i].keys.first == itemName){
      for(int j=0;j<reviewDescriptionList[i].values.first.length;j++){
        reviewDescriptionWidget.add(Text('${j+1}. ${reviewDescriptionList[i].values.first[j]} '));
        reviewDescriptionWidget.add(SizedBox(height: 10.0,));
      }
    }
  }


  return Container(
    padding: EdgeInsets.all(10.0),
    width: MediaQuery.of(context).size.width,
    height: 400.0,
    child: Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('평가요소: ${itemName}', style: TextStyle(fontSize: 30.0, color: Colors.grey),),
          Divider(),
          SizedBox(height: 10.0,),
          Text('다음 항목에 주의해서 곡을 평가해주세요!', style: TextStyle(fontSize: 17.0),),
          SizedBox(height: 10.0,),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: reviewDescriptionWidget
          ),

        ],
      ),
    ),
  );
}