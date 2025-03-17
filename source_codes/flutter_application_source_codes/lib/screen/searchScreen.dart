import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as gx;
import 'package:piano_acquisition_application/networkInfo.dart';
import 'package:piano_acquisition_application/screen/scoreInfoScreen.dart';
import '../main.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  late TextEditingController searchTextEditController;


  List<Widget> _recentSearchList = [ ];


  @override
  void initState(){
    super.initState();
    searchTextEditController = TextEditingController();
    _recentSearchList = [];
  }

  @override
  void dispose(){
    super.dispose();
    searchTextEditController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            left: 10.0,
            right: 10.0
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
                Container(
                  margin: EdgeInsets.only(
                    top: 10.0
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: 70.0,
                  child: TextField(
                    controller: searchTextEditController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '곡 이름을 입력하세요.',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: (){

                        },
                      )
                    ),
                    onChanged: (val){
                        setState(() {

                        });
                    },
                    onEditingComplete: (){

                    },
                  ),
                ),
              SizedBox(height: 20.0,),
              Text('곡 목록'),
              Expanded(
                flex: 1,
                child: FutureBuilder(
                  future: _getSearchData(),
                  builder: (context, snapshot){

                    if(searchTextEditController.text.length == 0){
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('곡을 입력해주세요.')
                        ],
                      );
                    }
                    else if(snapshot.hasData){
                      _recentSearchList = [];
                      for(int i=0;i<snapshot.data['song_id_list'].length; i++){
                        _recentSearchList.add(
                          InkWell(
                            onTap: (){
                              final songInfoController = gx.Get.put(SongInfoController());

                              songInfoController.setDuration(snapshot.data['song_duration_list'][i].toString());
                              songInfoController.setSongName(snapshot.data['song_name_list'][i]);
                              songInfoController.setComposer(snapshot.data['song_composer_list'][i]);
                              songInfoController.setSongId(snapshot.data['song_id_list'][i].toString());
                              Navigator.push(context, MaterialPageRoute(builder: (_)=>ScoreInfoScreen()));
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: 5.0
                              ),
                              width: MediaQuery.of(context).size.width,
                              height: 30.0,
                              child: Text('${snapshot.data['song_name_list'][i]}', style: TextStyle(color: Colors.black, fontSize: 15.0),),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(width: 0.5, color: Colors.grey.shade500)
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return Container(
                        child: Column(
                            children: _recentSearchList
                        ),
                      );
                    }else{
                      return CircularProgressIndicator();
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  Future<dynamic> _getSearchData() async{
    _recentSearchList = [];
    Dio dio = Dio();

    try{
      Response res  = await dio.get(SERVERIP+'/api/search/getSearchText',
          queryParameters: {
            'search_text' : searchTextEditController.text
          },
      );
      return res.data;
    }catch (e){
      return;
    }finally{
      dio.close();
    }
  }
}
