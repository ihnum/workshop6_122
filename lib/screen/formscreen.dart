import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../model/student.dart';

class Formscreen extends StatefulWidget {
  const Formscreen({super.key});

  @override
  State<Formscreen> createState() => _FormscreenState();
}

class _FormscreenState extends State<Formscreen> {
  final formKey = GlobalKey<FormState>();
  Student myStudent = Student(
    fname: "", lname: "", email: "", score: "");
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  CollectionReference _studentCollection = FirebaseFirestore.instance.collection("student");

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder:(context,snapshot){
        if(snapshot.hasError){
          return Scaffold(
            appBar: AppBar(
              title: const Text("Error"),
            ),
            body:Center(
              child: Text("${snapshot.error}"),
            ),
          );
        }
        if(snapshot.connectionState == ConnectionState.done){
              return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 49, 224, 157),
        title: const Text("บันทึกคะแนน"),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ชื่อ",style: TextStyle(fontSize: 20),),
                TextFormField(
                  validator: 
                  RequiredValidator(errorText: "กรุณาป้อนชื่อ"),
                  onSaved: (fname) {
                    myStudent.fname = fname!;
                  },
                ),
                const SizedBox(height: 20),
          
                const Text("นามสกุล",style: TextStyle(fontSize: 20),),
                TextFormField(
                  validator: 
                  RequiredValidator(errorText: "กรุณาป้อนนามสกุล"),
                  onSaved: (lname) {
                    myStudent.lname = lname!;
                  },
                ),
                const SizedBox(height: 20),
          
                const Text("อีเมล",style: TextStyle(fontSize: 20),),
                TextFormField(
                  validator: MultiValidator([
                    EmailValidator(errorText: "รูปแบบอีเมลไม่ถูกต้อง"),
                    RequiredValidator(errorText: "กรุณาป้อนอีเมล"),
                  ]),
                  onSaved: (email) {
                    myStudent.email = email!;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                const Text("คะแนน",style: TextStyle(fontSize: 20),),
                TextFormField(
                  keyboardType: TextInputType.number,
                  validator: 
                  RequiredValidator(errorText: "กรุณาป้อนคะแนน"),
                  onSaved: (score) {
                    myStudent.score = score!;
                  },
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 49, 224, 157),),
                    
                    onPressed: () async { 
                      if(formKey.currentState!.validate()){
                        formKey.currentState!.save();
                        await _studentCollection.add({
                          "fname": myStudent.fname,
                          "lname": myStudent.lname,
                          "email": myStudent.email,
                          "score": myStudent.score,
                        });
                        formKey.currentState!.reset();
                      
                      
                      //print("${myStudent.fname} ${myStudent.lname} ${myStudent.email} ${myStudent.score}");
                      }
                    },
                    child: Text("บันทึก"),
                  ),
                ),
              ],
          ),
          ),
        ),
      ),
    );

    }
    return const Scaffold(
      body : Center(
        child:CircularProgressIndicator() ,
      ),
    );
    }
);






  }
}