import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sketch_day/screens/main/user_page/update_password_page.dart';

import '../../../utils/authService.dart';
import '../../../widgets/show_loading_dialog.dart';
import '../../login/login_page.dart';

class Mypage extends StatefulWidget {
  Mypage({Key? key}) : super(key: key);

  @override
  _MypageState createState() => _MypageState();
}

class _MypageState extends State<Mypage> {
  final _authService = AuthService();

  Future<Map<String, dynamic>> fetchData() async {
    final url = '${dotenv.env['BASE_URL']}/mypage/userInfo';
    final accessToken = await _authService.readAccessToken() ?? '';
    final response = await _authService.get(url, accessToken);

    final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
    print(responseJson);

    if (response.statusCode == 200) {
      return responseJson['data'];
    } else {
      throw Exception('유저 데이터 조회 실패');
    }
  }

  Future<void> logout(BuildContext context) async {
    await _authService.deleteTokens();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  Future<bool?> showConfirmationDialog(
      BuildContext context, String message, Function onConfirm) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('예'),
              onPressed: () async {
                Navigator.of(context).pop(true);
                await onConfirm();
              },
            ),
            TextButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> signout(BuildContext context) async {
    bool? confirmed = await showConfirmationDialog(
      context,
      '모든 데이터가 제거됩니다.\n정말로 회원탈퇴 하시겠습니까?',
      () async {
        showLoadingDialog(context);
        try {
          final url = '${dotenv.env['BASE_URL']}/auth/deleteUser';
          final accessToken = await _authService.readAccessToken() ?? '';
          final response = await _authService.delete(url, accessToken);
          Navigator.pop(context);

          if (response.statusCode == 200) {
            await _authService.deleteTokens();
            showToast('회원탈퇴 되었습니다.');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
            );
          } else {
            showToast('회원탈퇴에 실패하였습니다');
          }
        } catch (e) {
          showToast('회원탈퇴에 실패하였습니다');
        }
      },
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('오류가 발생했습니다.');
        } else {
          var data = snapshot.data;
          return Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20.0, right: 20, bottom: 10.0),
                  child: Text(
                    '${data?['name']}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
                  child: Text(
                    '생년월일 | ${data?['birth']}',
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, bottom: 10.0),
                  child: Text(
                    'E-mail | ${data?['auth_email']}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdatePasswordPage()),
                    );
                  },
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Text(
                      '비밀번호 수정',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () => {
                    showConfirmationDialog(
                      context,
                      '로그아웃 하시겠습니까?',
                      () => logout(context),
                    )
                  },
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Text(
                      '로그아웃',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () => signout(context),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Text(
                      '회원탈퇴',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
