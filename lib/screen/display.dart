import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../model/student.dart';

class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  final _firestore = FirebaseFirestore.instance;

  Future<void> deleteStudent(String documentId) async {
    await _firestore.collection('student').doc(documentId).delete();
  }

  Future<void> updateStudent(String documentId, Student student) async {
    await _firestore.collection('student').doc(documentId).update({
      "fname": student.fname,
      "lname": student.lname,
      "email": student.email,
      "score": student.score,
    });
  }

  Future<void> showEditDialog(DocumentSnapshot document) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => EditStudentDialog(
        document: document,
        onSave: updateStudent,
      ),
    );
  }

  Future<void> showDeleteConfirmation(String documentId) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบข้อมูล'),
          content: const Text('คุณต้องการลบข้อมูลจริงๆ ใช่ไหมครับ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                await deleteStudent(documentId);
                Navigator.pop(context);
              },
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("รายงานคะแนนสอบ"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 138, 224, 174),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("student").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final document = snapshot.data!.docs[index];

              return Container(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    child: FittedBox(
                      child: Text(document["score"]),
                    ),
                  ),
                  title: Text(
                    document["fname"] + " " + document["lname"],
                  ),
                  subtitle: Text(document["email"]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await showEditDialog(document);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await showDeleteConfirmation(document.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EditStudentDialog extends StatefulWidget {
  const EditStudentDialog({super.key, required this.document, required this.onSave});

  final DocumentSnapshot document;
  final Future<void> Function(String documentId, Student student) onSave;

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController fnameController;
  late final TextEditingController lnameController;
  late final TextEditingController emailController;
  late final TextEditingController scoreController;

  @override
  void initState() {
    super.initState();
    fnameController = TextEditingController(text: widget.document["fname"] ?? "");
    lnameController = TextEditingController(text: widget.document["lname"] ?? "");
    emailController = TextEditingController(text: widget.document["email"] ?? "");
    scoreController = TextEditingController(text: widget.document["score"] ?? "");
  }

  @override
  void dispose() {
    fnameController.dispose();
    lnameController.dispose();
    emailController.dispose();
    scoreController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;

    final student = Student(
      fname: fnameController.text,
      lname: lnameController.text,
      email: emailController.text,
      score: scoreController.text,
    );

    try {
      await widget.onSave(widget.document.id, student);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("แก้ไขข้อมูลไม่สำเร็จ: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('แก้ไขข้อมูล'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: fnameController,
                decoration: const InputDecoration(labelText: "ชื่อ"),
                validator: RequiredValidator(errorText: "กรุณาป้อนชื่อ").call,
              ),
              TextFormField(
                controller: lnameController,
                decoration: const InputDecoration(labelText: "นามสกุล"),
                validator:
                RequiredValidator(errorText: "กรุณาป้อนนามสกุล").call,
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "อีเมล"),
                keyboardType: TextInputType.emailAddress,
                validator: MultiValidator([
                  EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง"),
                  RequiredValidator(errorText: "กรุณาป้อนอีเมล"),
                ]).call,
              ),
              TextFormField(
                controller: scoreController,
                decoration: const InputDecoration(labelText: "คะแนน"),
                keyboardType: TextInputType.number,
                validator: RequiredValidator(errorText: "กรุณาป้อนคะแนน").call,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ยกเลิก'),
        ),
        TextButton(
          onPressed: save,
          child: const Text('บันทึก'),
        ),
      ],
    );
  }
}