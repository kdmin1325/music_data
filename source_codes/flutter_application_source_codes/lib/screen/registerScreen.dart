import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:piano_acquisition_application/networkInfo.dart';
import 'package:piano_acquisition_application/screen/loginScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  int _isIdDuplicated = 1;
  bool _isObsecure = true;

  late TextEditingController _idController;
  late TextEditingController _passwdController;
  late TextEditingController _nameController;
  late TextEditingController _phNumController;
  late TextEditingController _universityController;
  late TextEditingController _departmentController;
  late TextEditingController _jobController;

  @override
  void initState(){
    super.initState();

    _idController = TextEditingController();
    _passwdController = TextEditingController();
    _nameController = TextEditingController();
    _phNumController = TextEditingController();
    _universityController = TextEditingController();
    _departmentController = TextEditingController();
    _jobController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();

    _idController.dispose();
    _passwdController.dispose();
    _nameController.dispose();
    _phNumController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _jobController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 20.0),
                  width: MediaQuery.of(context).size.width,
                  height: 50.0,
                  child: Text('회원가입을 진행합니다.', style: TextStyle(fontSize: 25.0),),
                ),
              ),
              Expanded(
                flex: 9,
                child: Container(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Divider(),
                        Container(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                          width: MediaQuery.of(context).size.width,
                          height: 70.0,
                          child: TextField(
                            controller: _idController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '아이디를 입력해주세요.',
                                suffixIcon: TextButton(
                                  onPressed: _checkDuplicated,
                                  child: Text('중복확인', style: TextStyle(color: Colors.black),),
                                )
                            ),
                            onTap: (){
                              _isIdDuplicated = 1;
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                          height: 70.0,
                          child: TextField(
                            controller: _passwdController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '비밀번호를 입력해주세요.',
                                suffixIcon: GestureDetector(
                                  onTapDown: (val){
                                    setState(() {
                                      _isObsecure = false;
                                    });
                                  },
                                  onTapUp: (val){
                                    setState(() {
                                      _isObsecure = true;
                                    });
                                  },
                                  child: Icon(Icons.remove_red_eye_outlined),
                                )
                            ),
                            obscureText: _isObsecure,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                          height: 70.0,
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '이름을 입력해주세요.'
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                          height: 70.0,
                          child: TextField(
                            controller: _phNumController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '전화번호를 입력해주세요.(010-xxxx-xxxx)'
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                          height: 70.0,
                          child: TextField(
                            controller: _departmentController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '학과를 입력해주세요.'
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                          height: 70.0,
                          child: TextField(
                            controller: _universityController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '대학교를 입력해주세요.'
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                          height: 70.0,
                          child: TextField(
                            controller: _jobController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '직업을 입력해주세요.'
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
                          width: MediaQuery.of(context).size.width,
                          height: 70.0,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)
                                ),
                                backgroundColor: Colors.red
                            ),
                            onPressed: _register,
                            child: Text('회원가입', style: TextStyle(color: Colors.white),),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _checkDuplicated() async{
    Dio dio = Dio();
    String user_id = _idController.text;

    try{
      Response res = await dio.get(
          SERVERIP+'/api/user/isIdDuplicated',
          queryParameters: {
            'user_id' : user_id
          },
          onReceiveProgress: (val1, val2){}
      );

      if(_idController.text =='') {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text('아이디를 입력해주세요.'),
          );
        });
      } else {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text('사용가능한 아이디입니다.'),
          );
        });
        _isIdDuplicated = 0;
      }

    }catch(e){
      if(_idController.text ==''){
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text('아이디를 입력해주세요.'),
          );
        });
      }else{
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text('이미 존재하는 아이디입니다.'),
          );
        });
      }
      return 1;
    }finally{
      dio.close();
    }
  }

  _register() async{
    if(_isIdDuplicated == 1){
      showDialog(context: context, builder: (context){
        return AlertDialog(
          title: Text('아이디 중복 체크를 해주세요.'),
        );
      });
    }else{
      Dio dio = Dio();
      print("0번쨰");

      String user_id = _idController.text;
      String user_pwd = _passwdController.text;
      String user_name = _nameController.text;

      String ph_num = _phNumController.text;
      String department = _departmentController.text;
      String university = _universityController.text;
      String job = _jobController.text;

      Map<String, dynamic> newUserData ={
        'user_id' : user_id,
        'user_pwd' : user_pwd,
        'user_name' : user_name,
        'ph_num' : ph_num,
        'department' : department,
        'university' : university,
        'job': job
      };

      try {
        List<String> num = user_id.split("");
        if (num.length >= 3) {
          print("아이디 유효");
        } else {
          showDialog(context: context, builder: (_){
            return AlertDialog(
              content: Container(child: Text('아이디를 3자리 이상 입력해주세요'),),
            );
          });
          dio.close();
          return;
        }

        num = user_pwd.split("");
        /*
        if (num.length >= 8) {
          for (int i = 2; i < num.length; i++){
            if(num[i] != num[i - 1] && num[i] != num[i - 2]){
            } else {
              showDialog(context: context, builder: (_){
                return AlertDialog(
                  content: Container(child: Text('비밀번호에 같은 문자가 3번 이상 반복됩니다.'),),
                );
              });
              dio.close();
              return;
            }
          }
        } else {
          showDialog(context: context, builder: (_){
            return AlertDialog(
              content: Container(child: Text('비밀번호를 8자리 이상 입력해주세요'),),
            );
          });
          dio.close();
          return;
        }

         */

        num = ph_num.split("");
        if (num.length == 13) {
          if (num[3] == '-' && num[8] == '-') {
            num.removeAt(8);
            num.removeAt(3);
            for (int i = 0; i < 10; i++) {
              int.parse(num[i]);
            }
            print("전화번호가 유효합니다.");
          } else {
            showDialog(context: context, builder: (_){
              return AlertDialog(
                content: Container(child: Text('전화번호 형식을 다시 확인해주세요'),),
              );
            });
            dio.close();
            return;
          }
        } else {
          showDialog(context: context, builder: (_){
            return AlertDialog(
              content: Container(child: Text('전화번호 길이가 맞지 않습니다'),),
            );
          });
          dio.close();
          return;
        }
      } catch (e) {
        showDialog(context: context, builder: (_){
          return AlertDialog(
            content: Container(child: Text('전화번호를 다시 확인해주세요'),),
          );
        });
        dio.close();
        return;
      }

      try {
        Response res = await dio.post(
          SERVERIP+'/api/user/register',
          data: newUserData,
          onReceiveProgress: (val1, val2){
            Navigator.pop(context);
            showDialog(context: context, builder: (_){
              return AlertDialog(
                title: Text('회원가입 성공'),
                actions: [
                  ElevatedButton(onPressed: (){
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>LoginScreen()), (route) => false);
                  }, child: Text('로그인 하기'))
                ],
              );
            });
          },
          onSendProgress: (val1, val2){
            showDialog(context: context, builder: (_){
              return AlertDialog(
                content: Container(
                  width: 70.0,
                  height: 50.0,
                  child: Row(
                    children: [
                      Text('가입 중입니다.'),
                      SizedBox(width: 5.0,),
                      CircularProgressIndicator()
                    ],
                  ),
                ),
              );
            });
          },
        );

      } catch(e) {
        showDialog(context: context, builder: (_){
          return AlertDialog(
            content: Container(child: Text('회원가입 실패'),),
          );
        });
      } finally {
        dio.close();
      }
    }
  }
}
