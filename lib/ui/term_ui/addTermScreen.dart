import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'settingTermScreen.dart';

class AddTermScreen extends StatefulWidget {
  @override
  State<AddTermScreen> createState() => _AddTermScreenState();
}

class _AddTermScreenState extends State<AddTermScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _englishTermController = [
    TextEditingController()
  ];
  final List<TextEditingController> _vietnameseDefinitionController = [
    TextEditingController()
  ];
  String _visibility = 'Mọi người';

  User? user;
  String userEmail = 'No Email';
  String userName = 'No Name';

  @override
  void initState() {
    super.initState();
    getUser();
    getTermsFromFirestore();
  }

  void getUser() {
    user = FirebaseAuth.instance.currentUser;
    userEmail = user?.email ?? 'No Email';
  }

  Future<void> getTermsFromFirestore() async {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    final QuerySnapshot querySnapshot = await usersCollection
        .where('userEmail', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot userDoc = querySnapshot.docs.first;
      setState(() {
        userName = userDoc['userName'] ?? 'No Username';
      });
    } else {
      setState(() {
        userName = 'No Username Found';
      });
    }
  }

  void _addNewField() {
    setState(() {
      _englishTermController.add(TextEditingController());
      _vietnameseDefinitionController.add(TextEditingController());
    });
  }

  void _removeField(int index) {
    setState(() {
      _englishTermController.removeAt(index);
      _vietnameseDefinitionController.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Học Phần'),
        backgroundColor: Color(0xFF4254FE),
        foregroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewField,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingTermScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () async {
              final CollectionReference termsCollection =
                  FirebaseFirestore.instance.collection('terms');

              List<String> englishTerms = _englishTermController
                  .map((controller) => controller.text)
                  .toList();
              List<String> vietnameseDefinitions =
                  _vietnameseDefinitionController
                      .map((controller) => controller.text)
                      .toList();

              Map<String, dynamic> data = {
                'title': _titleController.text,
                'userEmail': userEmail,
                'userName': userName,
                'english': englishTerms.map((term) => term.trim()).toList(),
                'vietnamese': vietnameseDefinitions
                    .map((definition) => definition.trim())
                    .toList(),
                'visibility': _visibility,
                'favorite': false,
              };

              await termsCollection.add(data);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Term has been added successfully.'),
                ),
              );

              Navigator.pop(context,
                  true); // Truyền giá trị true khi quay lại trang trước đó
            },
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Row(
                children: [
                  Text(
                    'Chế độ xem:', // Display the current visibility
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  DropdownButton2<String>(
                    value: _visibility,
                    onChanged: (String? newValue) {
                      setState(() {
                        _visibility = newValue!;
                      });
                    },
                    items: <String>['Mọi người', 'Chỉ mình tôi']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    dropdownDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5.0),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16.0),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _englishTermController.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Dismissible(
                      key: Key('$index'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        _removeField(index);
                      },
                      child: Column(
                        children: [
                          TextField(
                            controller: _englishTermController[index],
                            decoration: InputDecoration(
                              labelText: 'Thuật ngữ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      _removeField(index);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: _addNewField,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          TextField(
                            controller: _vietnameseDefinitionController[index],
                            decoration: InputDecoration(
                              labelText: 'Định nghĩa',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                          const SizedBox(height: 16.0),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24.0),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Quét Tài Liệu'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF4254FE),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () {
                  // Xử lý khi nhấn "Quét Tài Liệu"
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
