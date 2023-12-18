import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/todo.dart';

class ItemList extends StatelessWidget {
  final String transaksiDocId;
  final Todo todo;
  const ItemList({super.key, required this.transaksiDocId, required this.todo});

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    CollectionReference todoCollection = _firestore.collection('Todos');
    TextEditingController _titleController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

    Future<void> deleteTodo() async {
      await _firestore.collection('Todos').doc(transaksiDocId).delete();
    }

    Future<void> updateTodo() async {
      await _firestore.collection('Todos').doc(transaksiDocId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'isComplete': false,
      });
    }

    return const Placeholder();
  }
}
