import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../utils/authService.dart';
import 'create_post/view_diary_page.dart';

class Diary extends StatefulWidget {
  @override
  _DiaryState createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  late Future<List<Map<String, dynamic>>> _futureDiaries;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _futureDiaries = _fetchDiaries();
  }

  Future<List<Map<String, dynamic>>> _fetchDiaries() async {
    final url = '${dotenv.env['BASE_URL']}/diary/lists';
    final accessToken = await _authService.readAccessToken() ??
        ''; // 액세스 토큰이 null인 경우 빈 문자열로 설정
    final response = await _authService.get(url, accessToken);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      List<Map<String, dynamic>> result = [];
      data.forEach((key, value) {
        result.add({'year_month': key, 'diaries': value});
      });
      print(utf8.decode(response.bodyBytes));
      return result;
    } else {
      throw Exception('다이어리 조회에 실패했습니다.');
    }
  }

  // 새로 고침
  Future<void> _refreshDiaries() async {
    setState(() {
      _futureDiaries = _fetchDiaries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: RefreshIndicator(
        onRefresh: _refreshDiaries,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureDiaries,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final diaries = snapshot.data!;
              return ListView.builder(
                itemCount: diaries.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 15),
                        child: Text(
                          diaries[index]['year_month'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(5),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        itemCount: diaries[index]['diaries'].length,
                        itemBuilder: (context, index2) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewDiaryPage(
                                      diaryId: diaries[index]['diaries'][index2]
                                          ['diary_id']),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: diaries[index]['diaries'][index2]
                                          ['image_url'] ==
                                      null
                                  ? Image.asset('images/logo_v2.png',
                                      fit: BoxFit.cover)
                                  : Image.network(
                                      diaries[index]['diaries'][index2]
                                          ['image_url'],
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          );
                        },
                      ),
                      if (index < diaries.length - 1) // 구분선
                        const Divider(
                          color: Colors.black12,
                          thickness: 1,
                          height: 20,
                        ),
                    ],
                  );
                },
              );
            } else if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Center(
                child: Image.asset('images/no_diary_img.png'),
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
      )),
    );
  }
}
