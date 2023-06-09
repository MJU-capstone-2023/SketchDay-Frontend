import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sketch_day/screens/main/create_post/view_diary_page.dart';

import '../../../utils/authService.dart';
import '../../../widgets/show_loading_dialog.dart';
import '../main_page.dart';

class UpdateDiaryPage extends StatefulWidget {
  final String diaryId;
  final DateTime diaryDate;

  const UpdateDiaryPage(
      {Key? key, required this.diaryId, required this.diaryDate})
      : super(key: key);

  @override
  _UpdateDiaryPageState createState() => _UpdateDiaryPageState();
}

class _UpdateDiaryPageState extends State<UpdateDiaryPage> {
  Future<Map<String, dynamic>>? _diary;
  final _authService = AuthService();
  DateTime selectedDate = DateTime.now();
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _diary = _getDiaryById();
    selectedDate = widget.diaryDate;
  }

  // 날짜 선택
  void showDatePickerDialog() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // 기존 일기 내용 GET
  Future<Map<String, dynamic>> _getDiaryById() async {
    final url = '${dotenv.env['BASE_URL']}/diary/${widget.diaryId}';
    final accessToken = await _authService.readAccessToken() ?? '';
    final response = await _authService.get(url, accessToken);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
      final diary = responseJson['res'][0];
      print(diary);
      return diary;
    } else {
      throw Exception('다이어리 조회에 실패했습니다.');
    }
  }

  // 일기 수정
  Future<void> _updateDiaryById() async {
    showLoadingDialog(context);
    final url = '${dotenv.env['BASE_URL']}/diary/update?id=${widget.diaryId}';
    final accessToken = await _authService.readAccessToken() ?? '';

    // 일기 내용 가져오기
    final content = _textEditingController.text;
    final response = await _authService.patch(
      url,
      accessToken,
      body: {
        "new_content": content,
        "new_emo": "1",
        "new_wea": "3",
        "new_date": selectedDate.toIso8601String().split('T')[0]
      },
    );
    final responseJson = jsonDecode(utf8.decode(response.bodyBytes));
    print(responseJson);
    Navigator.pop(context);

    if (response.statusCode == 200) {
      showToast('수정 되었습니다.');
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => ViewDiaryPage(diaryId: widget.diaryId)),
              (route) => route.isFirst
      );
    } else {
      showToast('다이어리 수정에 실패했습니다.');
      throw Exception('다이어리 수정에 실패했습니다.');
    }
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
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _diary,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 40.0, left: 10.0, right: 10.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context); // 이전 페이지로 돌아가기
                        },
                        icon: const Icon(Icons.close),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _updateDiaryById(),
                        child: const Text(
                          '저장',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDatePickerDialog();
                        },
                        icon: const Icon(Icons.arrow_drop_down),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: 날씨 선택 다이얼로그 표시
                        },
                        icon: const Icon(Icons.wb_sunny),
                      ),
                      IconButton(
                        onPressed: () {
                          // TODO: 기분 선택 다이얼로그 표시
                        },
                        icon: const Icon(Icons.emoji_emotions),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 30.0, horizontal: 24.0),
                    child: TextField(
                      controller: _textEditingController
                        ..text = snapshot.data!['content'] ?? '',
                      expands: true,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontSize: 16.0,
                        height: 1.8,
                      ),
                      decoration: InputDecoration(
                        hintText: '오늘 하루를 기록해보세요!',
                        contentPadding: const EdgeInsets.all(20.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
