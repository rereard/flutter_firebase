import 'package:flutter/material.dart';
import 'package:todo_list/database_helper.dart';
import 'package:todo_list/todo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo-List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoApp(),
    );
  }
}

class TodoApp extends StatefulWidget {
  const TodoApp({Key? key}) : super(key: key);

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _titleEditController = TextEditingController();
  final TextEditingController _descEditController = TextEditingController();
  final dbHelper = DatabaseHelper();
  List<Todo> _todos = [];
  List<Todo> _searchtodos = [];
  String keyword = '';
  bool validate = false;

  @override
  void initState() {
    refreshItemList();
    super.initState();
  }

  void refreshItemList() async {
    final todos = await dbHelper.getAllTodos();
    setState(() {
      _todos = todos;
      _searchtodos = todos;
      keyword = '';
    });
    _titleController.clear();
    _descController.clear();
    _searchController.clear();
  }

  void searchItems() async {
    setState(() {
      keyword = _searchController.text.trim();
    });
    if (keyword.isNotEmpty) {
      final todos = await dbHelper.getTodoByTitle(keyword);
      setState(() {
        _searchtodos = todos;
      });
    } else {
      refreshItemList();
    }
  }

  void addItem(String title, String desc) async {
    final todo = Todo(title: title, description: desc, completed: false);
    await dbHelper.insertTodo(todo);
    refreshItemList();
  }

  void updateItem(Todo todo, bool completed) async {
    final item = Todo(
      id: todo.id,
      title: todo.title,
      description: todo.description,
      completed: completed,
    );
    await dbHelper.updateTodo(item);
    refreshItemList();
  }

  void deleteItem(int id) async {
    await dbHelper.deleteTodo(id);
    refreshItemList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _todos.isNotEmpty
                ? TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: keyword.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                refreshItemList();
                                _searchController.clear();
                                keyword = '';
                              },
                              icon: const Icon(Icons.clear))
                          : null,
                      border: const UnderlineInputBorder(),
                    ),
                    onChanged: (_) {
                      searchItems();
                    },
                  )
                : null,
          ),
          Expanded(
            child: _todos.isNotEmpty
                ? Card(
                    child: ListView.builder(
                      itemCount: _searchtodos.length,
                      padding: const EdgeInsets.only(bottom: 70.0),
                      itemBuilder: (context, index) {
                        var todo = _searchtodos[index];
                        return ListTile(
                          tileColor:
                              todo.completed ? Colors.grey.shade200 : null,
                          leading: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteItem(todo.id!);
                            },
                          ),
                          title: Text(
                            todo.title,
                            style: TextStyle(
                                decoration: todo.completed
                                    ? TextDecoration.lineThrough
                                    : null),
                          ),
                          subtitle: Text(todo.description),
                          trailing: todo.completed
                              ? IconButton(
                                  icon: const Icon(Icons.check_box),
                                  onPressed: () {
                                    updateItem(todo, !todo.completed);
                                  },
                                )
                              : IconButton(
                                  icon:
                                      const Icon(Icons.check_box_outline_blank),
                                  onPressed: () {
                                    updateItem(todo, !todo.completed);
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
                                updateItem(
                                    Todo(
                                        id: todo.id,
                                        title: _titleEditController.text,
                                        description: _descEditController.text,
                                        completed: todo.completed),
                                    todo.completed);
                              },
                            );
                          },
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Text(
                      "Belum ada Todo",
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                          fontSize: 23,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
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
                    addItem(_titleController.text, _descController.text);
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
