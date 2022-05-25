import 'dart:async';

import 'package:doclinked1/widgets/header.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final _formkey = GlobalKey<FormState>();

  String username;

  submit(){
    final form = _formkey.currentState;

    if(form.validate()){
      form.save();
      SnackBar snackbar = SnackBar(content: Text("Welcome $username"));
      _scaffoldkey.currentState.showSnackBar(snackbar);
      Timer(Duration(seconds: 2), (){
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldkey,
      appBar: header(context, titleText: "Set up your profile", removeBackButton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      "Create a username",
                      style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      autovalidateMode: AutovalidateMode.always, key: _formkey,
                      child: TextFormField(
                        validator: (val){
                          if(val.trim().length <3 || val.isEmpty){
                            return "Username is too short";
                          }
                          else if(val.trim().length > 12){
                            return "Username is too long";
                          }
                          else{
                            return null;
                          }
                        },
                        style: TextStyle(color: Colors.black),
                        onSaved: (val) => username = val,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Username",
                          labelStyle: TextStyle(
                            fontSize: 15.0,
                          ),
                          hintText: "Must be at least 3 characters",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 350.0,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
