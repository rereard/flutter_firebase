import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:todo_list/database_helper.dart';
import 'package:todo_list/model/todo.dart';
import 'package:todo_list/view/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _titleEditController = TextEditingController();
  final TextEditingController _descEditController = TextEditingController();
  // final dbHelper = DatabaseHelper();
  // List<Todo> _todos = [];
  // List<Todo> _searchtodos = [];
  String keyword = '';
  bool validate = false;
  bool isComplete = false;

  // @override
  //   void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   getTodo();
  // }
  // void initState() {
  //   refreshItemList();
  //   super.initState();
  // }

  Future<void> _signOut() async {
    await _auth.signOut();
    runApp(MaterialApp(
      home: new LoginPage(),
    ));
    print('were here');
  }

  // void refreshItemList() async {
  //   final todos = await dbHelper.getAllTodos();
  //   setState(() {
  //     _todos = todos;
  //     _searchtodos = todos;
  //     keyword = '';
  //   });
  //   _titleController.clear();
  //   _descController.clear();
  //   _searchController.clear();
  // }

  // void searchItems() async {
  //   setState(() {
  //     keyword = _searchController.text.trim();
  //   });
  //   if (keyword.isNotEmpty) {
  //     final todos = await dbHelper.getTodoByTitle(keyword);
  //     setState(() {
  //       _searchtodos = todos;
  //     });
  //   } else {
  //     refreshItemList();
  //   }
  // }

  Future<QuerySnapshot>? searchResultsFuture;
  Future<void> searchResult(String textEntered) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("Todos")
        .where("title", isGreaterThanOrEqualTo: textEntered)
        .where("title", isLessThan: textEntered + 'z')
        .get();

    setState(() {
      searchResultsFuture = Future.value(querySnapshot);
    });
  }

  // void addItem(String title, String desc) async {
  //   final todo = Todo(title: title, description: desc, completed: false);
  //   await dbHelper.insertTodo(todo);
  //   refreshItemList();
  // }

  // void updateItem(Todo todo, bool completed) async {
  //   final item = Todo(
  //     id: todo.id,
  //     title: todo.title,
  //     description: todo.description,
  //     completed: completed,
  //   );
  //   await dbHelper.updateTodo(item);
  //   refreshItemList();
  // }

  Future<void> updateTodo(docId) async {
    await _firestore.collection('Todos').doc(docId).update({
      'title': _titleEditController.text,
      'description': _descEditController.text,
      'isComplete': false,
    });
  }

  // void deleteItem(int id) async {
  //   await dbHelper.deleteTodo(id);
  //   refreshItemList();
  // }

  Future<void> deleteTodo(docId) async {
    await _firestore.collection('Todos').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference todoCollection = _firestore.collection('Todos');
    final User? user = _auth.currentUser;
    Future<void> addTodo() {
      return todoCollection.add({
        'title': _titleController.text,
        'description': _descController.text,
        'isComplete': isComplete,
        'uid': _auth.currentUser!.uid,
        // ignore: invalid_return_type_for_catch_error
      }).catchError((error) => print('Failed to add todo: $error'));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah anda yakin ingin logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Tidak'),
                    ),
                    TextButton(
                      onPressed: () {
                        _signOut();
                      },
                      child: const Text('Ya'),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus!.unfocus(),
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            // refreshItemList();
                            _searchController.clear();
                            setState(() {
                              keyword = _searchController.text.trim();
                            });
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          icon: const Icon(Icons.clear))
                      : null,
                  border: const UnderlineInputBorder(),
                ),
                onChanged: (_) {
                  setState(() {
                    keyword = _searchController.text.trim();
                  });
                  searchResult(keyword);
                  // searchItems();
                },
              )),
          Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _searchController.text.isEmpty
                      ? _firestore
                          .collection('Todos')
                          .where('uid', isEqualTo: user!.uid)
                          .snapshots()
                      : searchResultsFuture != null
                          ? searchResultsFuture!
                              .asStream()
                              .cast<QuerySnapshot<Map<String, dynamic>>>()
                          : const Stream.empty(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data == null || snapshot.data?.size == 0) {
                      return const Center(
                        child: Text(
                          "Tidak ada Todo",
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                              fontSize: 23,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    } else {
                      List<Todo> listTodo = snapshot.data!.docs.map((document) {
                        final data = document.data();
                        final String title = data['title'];
                        final String description = data['description'];
                        final bool isComplete = data['isComplete'];
                        final String uid = user!.uid;

                        return Todo(
                            description: description,
                            title: title,
                            isComplete: isComplete,
                            uid: uid);
                      }).toList();
                      return Card(
                        child: ListView.builder(
                          itemCount: listTodo.length,
                          padding: const EdgeInsets.only(bottom: 70.0),
                          itemBuilder: (context, index) {
                            var todo = listTodo[index];
                            var transaksiDocId = snapshot.data!.docs[index].id;
                            return ListTile(
                              tileColor:
                                  todo.isComplete ? Colors.grey.shade200 : null,
                              leading: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  deleteTodo(transaksiDocId);
                                  // deleteItem(todo.id!);
                                },
                              ),
                              title: Text(
                                todo.title,
                                style: TextStyle(
                                    decoration: todo.isComplete
                                        ? TextDecoration.lineThrough
                                        : null),
                              ),
                              subtitle: Text(todo.description),
                              trailing: todo.isComplete
                                  ? IconButton(
                                      icon: const Icon(Icons.check_box),
                                      onPressed: () {
                                        todoCollection
                                            .doc(transaksiDocId)
                                            .update({
                                          'isComplete': !todo.isComplete,
                                        });
                                        // updateItem(todo, !todo.completed);
                                      },
                                    )
                                  : IconButton(
                                      icon: const Icon(
                                          Icons.check_box_outline_blank),
                                      onPressed: () {
                                        todoCollection
                                            .doc(transaksiDocId)
                                            .update({
                                          'isComplete': !todo.isComplete,
                                        });
                                        // updateItem(todo, !todo.completed);
                                      },
                                    ),
                              onLongPress: () {
                                _titleEditController.text = todo.title;
                                _descEditController.text = todo.description;
                                dialog(
                                  context: context,
                                  isEdit: true,
                                  title: 'Edit todo',
                                  titleController: _titleEditController,
                                  descController: _descEditController,
                                  cancelBtnFunc: () {},
                                  okBtnFunc: () {
                                    updateTodo(transaksiDocId);
                                    // updateItem(
                                    //     Todo(
                                    //         id: todo.id,
                                    //         title: _titleEditController.text,
                                    //         description: _descEditController.text,
                                    //         completed: todo.completed),
                                    //     todo.completed);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      );
                    }

                    // : const Center(
                    //     child: Text(
                    //       "Belum ada Todo",
                    //       style: TextStyle(
                    //           fontStyle: FontStyle.italic,
                    //           color: Colors.grey,
                    //           fontSize: 23,
                    //           fontWeight: FontWeight.bold),
                    //     ),
                    //   ),
                  })),
        ],
      ),
      floatingActionButton: keyword.isEmpty
          ? FloatingActionButton(
              tooltip: "Tambahkan Todo",
              onPressed: () {
                dialog(
                  context: context,
                  title: 'Tambah todo',
                  titleController: _titleController,
                  descController: _descController,
                  cancelBtnFunc: () {
                    _titleController.text = '';
                    _descController.text = '';
                  },
                  okBtnFunc: () {
                    addTodo();
                    // addItem(_titleController.text, _descController.text);
                    _titleController.text = '';
                    _descController.text = '';
                  },
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<dynamic> dialog(
      {required BuildContext context,
      required String title,
      required TextEditingController titleController,
      required TextEditingController descController,
      required Function cancelBtnFunc,
      required Function okBtnFunc,
      bool? isEdit = false}) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 150,
            height: 150,
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Judul todo',
                    errorText: validate ? "Judul tidak boleh kosong" : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      validate = false;
                    });
                  },
                ),
                TextField(
                  controller: descController,
                  decoration:
                      const InputDecoration(labelText: 'Deskripsi todo'),
                  minLines: 1,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  validate = false;
                });
                cancelBtnFunc();
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.isEmpty) {
                  setState(() {
                    validate = true;
                  });
                } else {
                  okBtnFunc();
                  Navigator.pop(context);
                }
              },
              child: Text(isEdit! ? 'Edit' : 'Tambah'),
            ),
          ],
        );
      }),
    );
  }
}
