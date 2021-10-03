# Flutter with Sqlite

Sqlite is a local database that developers can use to store the data locally that is in the device itself instead of server.

So here we are going to implement the kind of crud operation of the user that we are going to save in the **Sqlite** and retrieve it later to display the data.

So let's begin

First of all we need to add certain dependencies under the dependencies section in the *pubspec.yaml* file which are listed in following section to enable our project for SQLite:
1. sqflite
2. path_provider

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: any
  path_provider: any
```
 

Then we are going to create a model folder inside the lib folder and create a model of user.

user.dart
```dart
class User {
  final int? id;
  final String name;
  final int age;
  final String country;
  final String? email;
  User(
      { this.id,
        required this.name,
        required this.age,
        required this.country,
        this.email});
  User.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        name = res["name"],
        age = res["age"],
        country = res["country"],
        email = res["email"];
  Map<String, Object?> toMap() {
    return {'id':id,'name': name, 'age': age, 'country': country, 'email': email};
  }
}
```

In order to store the data in SQLite we need to transform the object into Map so there are two functions to address it.
1. fromMap : It will convert from Map to User object.
2. toMap: It will convert from User object to Map


Now we are going to another directory **utils** under the lib section in which we'll create **database_helper.dart** to implement database operations.

database_helper.dart

```dart
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test_project/model/user.dart';

class DatabaseHelper{
  static final DatabaseHelper _databaseHelper=DatabaseHelper._createInstance();
  DatabaseHelper._createInstance();
  factory DatabaseHelper(){
    return _databaseHelper;
  }

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'demo.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,age INTEGER NOT NULL, country TEXT NOT NULL, email TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<int> insertUser(User user) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.insert('users', user.toMap());
    return result;
  }

  Future<int> updateUser(User user) async{
    int result= 0;
    final Database db=await initializeDB();
    result=await db.update(
      'users',
      user.toMap(),
      where: "id = ?",
      whereArgs: [user.id],
    );
    return result;
  }

  Future<List<User>> retrieveUsers() async {
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResult = await db.query('users');
    return queryResult.map((e) => User.fromMap(e)).toList();
  }

  Future<void> deleteUser(int id) async {
    final db = await initializeDB();
    await db.delete(
      'users',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<void> truncateDB() async {
    final db = await initializeDB();
    await db.execute("delete from users");
  }
}

```

We have created a singleton **DatabseHelper** class with the help of factory keyword. In dart **factory** keyword is used to create a constructor that would return only single instance of the class. This is the elegant way to make the singleton class in dart. We want to use single instance of the database handler in everywhere which would help us to save the memory and track the single state.  

**_createInstance** is the private named constructor to get the instance of the first time and factory constructor will return the same instance that we have created using the  _createInstance name constructor.

In this class we have written **initializeDB** asynchronous function to initialize the our database which will return an object of Database. To deal with asynchronous in flutter we have **Future** class and **async**, **await** keyword.

**getDatabasesPath** function will give us a default location of the database in which append our database name. In this case it is **demo.db**.

Now we are creating a table inside the database and have  written some functions to store, update and delete the data from the database.

First function is **insertUser** in which we are getting the object of user and convert it into the map to and pass it in the insert function of the database.

**updateUser** function will update the user in which it's mandatory to have a id in the User object to update the row on the base of user id.

**retrieveUsers** function will get all records from the database and return the list of Map. We are converting map to list.

**deleteUser** function only needs to pass an id to delete the records.

Finally we are create a function **truncateDB** to truncate the database.

Now It's time to get hands dirty on **main.dart** which is the main class to render the elements in our screen.

Here we have used **FutureBuilder** to get the initial data from the database then in case of insert we will hit the query and append the data in the same list.


```dart
class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  // This widget is the home page of your application.
  final String? title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}@override
  void initState() {
    super.initState();
    this.handler = DatabaseHelper();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {});
    });
  }
```

Here we are mainiting state if state is changed then it will directly reflect to the screen. So we will change our state after every transaction with the database so we can sync between screen and data.

We are mainiting the state of the **MyHomePage** state in the **_MyHomePageState** extended with the **State** class with override function *initState* function in which we will initialize the database and reset our state.

```dart
@override
  void initState() {
    super.initState();
    this.handler = DatabaseHelper();
    this.handler.initializeDB().whenComplete(() async {
      setState(() {});
    });
  }
```

Now we have used **Scaffold** which will provide us **AppBar** and **Body**.

Inside the body we have two section one for form to add or update the user another is to view the user list.

The first section is the form
```dart
Column(
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
                      Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                new Container(
                                    child: new RaisedButton(
                                  child: const Text('Submit'),
                                  onPressed: () async {
                                    User user = new User(
                                        name: nameController.text,
                                        age: int.parse(ageController.text),
                                        country: countryController.text,
                                        email: emailController.text);
                                    int result = await addUser(user);
                                    nameController.clear();
                                    ageController.clear();
                                    countryController.clear();
                                    emailController.clear();
                                    setState(() {});
                                  },
                                )),
                                new Container(
                                    child: new RaisedButton(
                                  child: const Text('Update'),
                                  onPressed: () async {
                                    _user.email = emailController.text;
                                    _user.age = int.parse(ageController.text);
                                    _user.country = countryController.text;
                                    _user.name = nameController.text;
                                    int result = await updateUser(_user);
                                    nameController.clear();
                                    ageController.clear();
                                    countryController.clear();
                                    emailController.clear();
                                    setState(() {});
                                  },
                                ))
                              ])
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
        )
```

In the above snippet we can see the some input box to let user enter his inputs and finally 

Another section is for User list in which we get the user with the help of FutureBuilder.

```dart
FutureBuilder(
      future: this.handler.retrieveUsers(),
      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, position) {
                return Dismissible(
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Icon(Icons.delete_forever),
                    ),
                    key: UniqueKey(),
                    onDismissed: (DismissDirection direction) async {
                      await this
                          .handler
                          .deleteUser(snapshot.data![position].id!);
                      setState(() {});
                    },
                    child: new GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _user = snapshot.data![position];
                        nameController.text = _user.name;
                        ageController.text = _user.age.toString();
                        countryController.text = _user.country;
                        emailController.text = _user.email!;
                      },
                      child: Column(
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
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(snapshot.data![position].age
                                        .toString()),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(snapshot
                                          .data![position].country
                                          .toString()),
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
                      ),
                    ));
              });
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
```

That's it project is ready to launch. Remaining code you can find in [Github](https://github.com/Akash2141/flutter-with-sqlite)