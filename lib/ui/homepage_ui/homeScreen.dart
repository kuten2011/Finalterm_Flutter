import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:midtermm/ui/homepage_ui/libraryScreen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onTabTapped;

  const HomeScreen({Key? key, required this.onTabTapped}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchText = '';
  String tt = 'Học phần, Sách giáo khoa, Học phần, ...';
  late User? user;
  late String userEmail = 'No Email';

  List<Map<String, dynamic>> terms = [];
  List<Map<String, dynamic>> userTerms = [];
  List<Map<String, dynamic>> similarTerms = [];
  List<Map<String, dynamic>> folders = [];
  List<Map<String, dynamic>> userFolders = [];

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    await getUser();
    await getTermsFromFirestore();
    await getFoldersFromFirestore();
  }

  Future<void> getUser() async {
    user = FirebaseAuth.instance.currentUser;
    userEmail = user?.email ?? 'No Email';
    print('Current User Email: $userEmail'); // Debug output
  }

  Future<void> getTermsFromFirestore() async {
    final CollectionReference termsCollection =
        FirebaseFirestore.instance.collection('terms');
    final QuerySnapshot querySnapshot = await termsCollection.get();

    setState(() {
      terms = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      userTerms =
          terms.where((term) => term['userEmail'] == userEmail).toList();
      similarTerms = terms
          .where((term) =>
              term['userEmail'] != userEmail &&
              term['visibility'] == 'Mọi người')
          .toList();
    });
  }

  Future<void> getFoldersFromFirestore() async {
    final CollectionReference foldersCollection =
        FirebaseFirestore.instance.collection('folders');
    final QuerySnapshot querySnapshotFolder = await foldersCollection.get();

    setState(() {
      folders = querySnapshotFolder.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      userFolders =
          folders.where((folder) => folder['userEmail'] == userEmail).toList();
    });
  }

  void _viewAllTerms(BuildContext context) {
    widget.onTabTapped(3);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Column(
          children: [
            // Thanh tìm kiếm cố định
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF4254FE),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25.0),
                  bottomRight: Radius.circular(25.0),
                ),
              ),
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: 8.0,
                top: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: tt,
                            hintStyle: TextStyle(
                              color: Color.fromARGB(255, 82, 82, 82),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF4254FE)),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromARGB(255, 82, 82, 82),
                              ),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: const Color.fromARGB(255, 82, 82, 82),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: const Color.fromARGB(255, 82, 82, 82),
                              ),
                              onPressed: () {
                                setState(() {
                                  searchText = '';
                                  tt = '';
                                });
                              },
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 16.0,
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(255, 255, 255, 255)
                                .withOpacity(0.8),
                            isDense: true,
                          ),
                          style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Học phần',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _viewAllTerms(context);
                            },
                            child: Text(
                              'Xem tất cả',
                              style: TextStyle(color: Color(0xFF4254FE)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: userTerms.length,
                        itemBuilder: (context, index) {
                          final userTerm = userTerms[index];
                          return EducationCard(
                            title: userTerm['title'],
                            userName: userTerm['userName'],
                            count: userTerm['english'] != null
                                ? userTerm['english'].length
                                : 0,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gợi ý học phần',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: similarTerms.length,
                        itemBuilder: (context, index) {
                          final similarTerm = similarTerms[index];
                          return EducationCard(
                            title: similarTerm['title'] ?? 'No Title',
                            userName: similarTerm['userName'] ?? 'No Username',
                            count: similarTerm['english'] != null
                                ? similarTerm['english'].length
                                : 0,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thư mục',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Handle "Xem tất cả" button tap
                            },
                            child: Text(
                              'Xem tất cả',
                              style: TextStyle(color: Color(0xFF4254FE)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: userFolders.length,
                        itemBuilder: (context, index) {
                          final userFolder = userFolders[index];
                          return FolderCard(
                            title: userFolder['title'],
                            userName: userFolder['userName'],
                            count: userFolder['termIDs'] != null
                                ? userFolder['termIDs'].length
                                : 0,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EducationCard extends StatelessWidget {
  final String title;
  final String userName;
  final int count;

  const EducationCard({
    Key? key,
    required this.title,
    required this.count,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.grey[400]!),
                  color: Color.fromARGB(255, 199, 212, 252),
                ),
                child: Text(
                  '$count thuật ngữ',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    '$userName   ',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16),
                  ),
                  Container(
                    padding: EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: Colors.grey[400]!),
                      color: Color.fromARGB(255, 210, 211, 212),
                    ),
                    child: Text(
                      'Giáo viên',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FolderCard extends StatelessWidget {
  final String title;
  final String userName;
  final int count;

  const FolderCard({
    Key? key,
    required this.title,
    required this.count,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.folder, size: 30),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.grey[400]!),
                  color: Color.fromARGB(255, 199, 212, 252),
                ),
                child: Text(
                  '$count học phần',
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '$userName   ',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
