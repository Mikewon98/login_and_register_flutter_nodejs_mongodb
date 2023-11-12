import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config.dart';
import '../model/todo_model.dart';

class MainScreen extends StatefulWidget {
  final dynamic token;
  const MainScreen({required this.token, super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String userId;
  final TextEditingController _toDoList = TextEditingController();
  final TextEditingController _toDoDescription = TextEditingController();
  List<TodoModel> todos = [];
  String title = "";
  String desc = "";

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(widget.token);

    userId = jwtDecodedToken['_id'];
    print(userId);
    getTodoList(userId);
  }

  void addToDo() async {
    if (_toDoList.text.isNotEmpty && _toDoDescription.text.isNotEmpty) {
      try {
        var reqBody = {
          "userId": userId,
          "title": _toDoList.text,
          "description": _toDoDescription.text,
        };

        var response = await http.post(
          Uri.parse(addTodo),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody),
        );

        var jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status']) {
          _toDoList.clear();
          _toDoDescription.clear();
          Navigator.pop(context);
          getTodoList(userId);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  // void getTodoList(userId) async {
  //   try {
  //     var response = await http.get(
  //       Uri.parse('http://192.168.43.177:3000/getUserTodoList/$userId'),
  //       headers: {"Content-Type": "application/json"},
  //     );

  //     debugPrint('Response body before decoding and casting to map: ');
  //     debugPrint(response.body
  //         .toString()); // this will print whatever the response body is before throwing exception or error

  //     var jsonResponse = jsonDecode(response.body);
  //     String title = jsonResponse['title'];
  //     String desc = jsonResponse['description'];

  //     setState(() {
  //       title = title;
  //       desc = desc;
  //     });
  //   } catch (e) {
  //     print("Error in getTodoList: $e");
  //   }
  // }

  Future getTodoList(userId) async {
    try {
      var response = await http.get(
        Uri.parse('http://192.168.43.177:3000/getUserTodoList/$userId'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print(jsonResponse.toString());

        if (jsonResponse is List) {
          // Loop through each item in the JSON array
          todos.clear(); // Clear the existing list
          for (var eachTodo in jsonResponse) {
            final todo = TodoModel(
              eachTodo['title'] ??
                  '', // Use the correct key to access the title
              eachTodo['description'] ??
                  '', // Use the correct key to access the description
            );
            todos.add(todo);
          }
          setState(() {});
        } else {
          print("Invalid JSON response format");
        }
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error in getTodoList: $e");
    }
  }

  // void deleteItem(id) async {
  //   var regBody = {"id": id};

  //   var response = await http.post(Uri.parse(deleteTodo),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(regBody));

  //   var jsonResponse = jsonDecode(response.body);
  //   if (jsonResponse['status']) {
  //     getTodoList(userId);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 20.0,
              left: 30.0,
              right: 30.0,
              bottom: 5.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 18.0,
                        horizontal: 5,
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 25.0,
                            child: IconButton(
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.remove('token');
                                Navigator.pushNamed(context, 'login');
                              },
                              icon: const Icon(
                                Icons.login,
                                size: 30.0,
                              ),
                            ),
                          ),
                          const Text("LogOut")
                        ],
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 10.0),
                const Text(
                  'ToDo with NodeJS + Mongodb',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8.0),
                const Text(
                  '5 Task',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 300,
              width: double.maxFinite,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: FutureBuilder(
                future: getTodoList(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: todos.length,
                          itemBuilder: (context, int index) {
                            return Slidable(
                              key: const ValueKey(0),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                dismissible:
                                    DismissiblePane(onDismissed: () {}),
                                children: [
                                  SlidableAction(
                                    backgroundColor: const Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                    onPressed: (BuildContext context) {
                                      // print('${items[index]['_id']}');
                                      // deleteItem(item.id);
                                    },
                                  ),
                                ],
                              ),
                              child: Card(
                                borderOnForeground: false,
                                child: ListTile(
                                  leading: const Icon(Icons.task),
                                  title: Text(todos[index].title),
                                  subtitle: Text(todos[index].description),
                                  trailing: const Icon(Icons.arrow_back),
                                ),
                              ),
                            );
                          },
                        ));
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    return const Center(
                      child: Text("Error fetching data"),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Add To-Do',
                  textAlign: TextAlign.center,
                ),
                content: Builder(
                  builder: (context) {
                    var height = MediaQuery.of(context).size.height;
                    var width = MediaQuery.of(context).size.width;

                    return SizedBox(
                      height: height * 0.35,
                      width: width * 0.8,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _toDoList,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Title",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _toDoDescription,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Description",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              addToDo();
                            },
                            child: const Text("Add"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        tooltip: 'Add-ToDo',
        child: const Icon(Icons.add),
      ),
    );
  }
}





// Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: ListView.builder(
//                   itemCount: todos.length,
//                   itemBuilder: (context, int index) {
//                     return Slidable(
//                       key: const ValueKey(0),
//                       endActionPane: ActionPane(
//                         motion: const ScrollMotion(),
//                         dismissible: DismissiblePane(onDismissed: () {}),
//                         children: [
//                           SlidableAction(
//                             backgroundColor: const Color(0xFFFE4A49),
//                             foregroundColor: Colors.white,
//                             icon: Icons.delete,
//                             label: 'Delete',
//                             onPressed: (BuildContext context) {
//                               // print('${items[index]['_id']}');
//                               // deleteItem(item.id);
//                             },
//                           ),
//                         ],
//                       ),
//                       child: Card(
//                         borderOnForeground: false,
//                         child: ListTile(
//                           leading: const Icon(Icons.task),
//                           title: Text(title),
//                           subtitle: Text(desc),
//                           trailing: const Icon(Icons.arrow_back),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

