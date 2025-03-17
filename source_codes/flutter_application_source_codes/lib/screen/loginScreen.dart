import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' as gx;
import 'package:get/instance_manager.dart';
import 'package:piano_acquisition_application/main.dart';
import 'package:piano_acquisition_application/networkInfo.dart';
import 'package:piano_acquisition_application/screen/mainScreen.dart';
import 'package:piano_acquisition_application/screen/registerScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final storage = FlutterSecureStorage();

  String access_token = '11';
  String user_id = '22';

  late TextEditingController _idTextController;
  late TextEditingController _passwordTextController;


  final formKey = GlobalKey<FormState>();

  @override
  void initState(){

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });

    _idTextController = TextEditingController();
    _passwordTextController = TextEditingController();

  }

  @override
  void dispose(){
    super.dispose();

    _idTextController.dispose();
    _passwordTextController.dispose();

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
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 50.0,),
                      Text('음원 데이터 평가 데이터 세트 구축 시스템', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                      Image.asset('assets/img/github_main_icon(200x200).png')
                    ],
                  ),
                ),
        
              ),
              Expanded(
                flex: 5,
                child: Container(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Container(
                            height: 70.0,
                            width: MediaQuery.of(context).size.width/3 *2,
                            child: TextFormField(
                              validator: (String? value){
                                if(value?.isEmpty ?? true) return '아이디를 입력해주세요.';
                                return null;
                              },
                              controller: _idTextController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: '아이디'
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Container(
                            height: 70.0,
                            width: MediaQuery.of(context).size.width/3 *2,
                            child: TextFormField(
                              validator: (String? value){
                                if(value?.isEmpty ?? true) return '비밀번호를 입력해주세요.';
                                return null;
                              },
                              controller: _passwordTextController,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: '비밀번호',
                              ),
                              obscureText: true,
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              bottom: 5.0
                            ),
                            height: 60.0,
                            width: MediaQuery.of(context).size.width/3 *2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)
                                  )
                              ),
                              onPressed: (){
                                if(formKey.currentState!.validate()){
                                  _login();
                                }
                              },
                              child: Text('시스템 로그인', style: TextStyle(color: Colors.white),),
                            ),
                          ),
                          Container(
                            height: 60.0,
                            width: MediaQuery.of(context).size.width/3 *2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0)
                                  )
                              ),
                              onPressed: (){
                                Navigator.push(context, MaterialPageRoute(builder: (_)=>RegisterScreen()));
                              },
                              child: Text('회원가입', style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _login() async{
    Dio dio = Dio();

    String user_id = _idTextController.text;
    String user_password = _passwordTextController.text;
    _passwordTextController.clear();

    showDialog(context: context, builder: (context){

      return AlertDialog(
          content: Container(
            width: 100.0,
            height: 70.0,
            child: Column(
              children: [
                Text('로그인 중 입니다.'),
                SizedBox(height: 5.0,),
                CircularProgressIndicator()
              ],
            ),
          )
      );
    });

    try{
      Response res = await dio.get(
          SERVERIP+'/api/user/login',
          queryParameters: {
            'user_id' : user_id,
            'user_pwd':user_password
          },
          onReceiveProgress: (val1, val2) async{
            Navigator.pop(context);
          }
      );

      if(res.data[1]['status'] == 'success'){
        user_id = _idTextController.text;
        access_token = res.data[2]['access_token'];
        int admin = res.data[3]['admin'];
        //access_token 저장
        await storage.write(key: 'login', value: access_token);
        await storage.write(key: 'user_id', value: user_id);
        await storage.write(key: 'admin', value: admin.toString());

        final statusController = Get.put(StatusController());
        statusController.setUserId(user_id);
        statusController.setAdmin(admin.toString());

        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>MainScreen()), (route) => false);
      }else{
      }

    }catch(e){
      showDialog(context: context, builder: (context){
        return AlertDialog(
          title: Text('비밀번호 오류'),
        );
      });
    }finally{
      dio.close();
    }



  }

  // accessToken 관리를 위한 메서드
  _asyncMethod() async {
    // read 함수로 key값에 맞는 정보를 불러오고 데이터타입은 String 타입
    // 데이터가 없을때는 null을 반환
    try{
      access_token = (await storage.read(key:'login'))!;
      user_id = (await storage.read(key: 'user_id'))!;
    }catch(e){
      return;
    }

    final statusController = Get.put(StatusController());
    statusController.setUserId(user_id);
    statusController.setAdmin((await storage.read(key: 'admin'))!);
    // user의 정보가 있다면 로그인 후 들어가는 첫 페이지로 넘어가게 합니다.
    if (access_token != null) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>MainScreen()), (route) => false);
    } else {
    }
  }
}
