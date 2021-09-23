import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test_project/model/user.dart';
import 'package:test_project/utils/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello World Flutter Application',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Home page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  // This widget is the home page of your application.
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DatabaseHelper handler;
  final nameController=TextEditingController();
  final ageController = TextEditingController();
  final countryController=TextEditingController();
  final emailController=TextEditingController();

  @override
  void initState() {
    super.initState();
    this.handler = DatabaseHelper();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(widget.title!),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 6,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            hintText: 'Enter your name',
                            labelText: 'Name'
                        ),
                      ),
                      TextFormField(
                        controller: ageController,
                        decoration: const InputDecoration(
                            hintText: 'Enter your age',
                            labelText: 'Age'
                        ),
                      ),
                      TextFormField(
                        controller: countryController,
                        decoration: const InputDecoration(
                            hintText: 'Enter your country',
                            labelText: 'Country'
                        ),
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                            hintText: 'Enter your email',
                            labelText: 'Email'
                        ),
                      ),
                      new Container(
                          child: new RaisedButton(
                            child: const Text('Submit'),
                            onPressed:  () async {
                              User user=new User(name:nameController.text,age:int.parse(ageController.text),country: countryController.text,email: emailController.text);
                              int result= await addUser(user);
                              setState(() {});
                            },
                          )),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: userWidget(),
            )
          ],
        ));
  }

  Widget userWidget() {
    return FutureBuilder(
      future: this.handler.retrieveUsers(),
      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemBuilder: (context, position) {
              return Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                12.0, 12.0, 12.0, 6.0),
                            child: Text(
                              snapshot.data![position].name,
                              style: TextStyle(
                                  fontSize: 22.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                12.0, 6.0, 12.0, 12.0),
                            child: Text(
                              snapshot.data![position].email.toString(),
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(snapshot.data![position].age.toString()),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  snapshot.data![position].country.toString()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 2.0,
                    color: Colors.grey,
                  )
                ],
              );
            },
            itemCount: snapshot.data?.length,
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<int> addUser(User user) async {
    return await this.handler.insertUser(user);
  }
}
