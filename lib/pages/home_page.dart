import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_app/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController textController = TextEditingController();

  void openNoteBox({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                decoration: InputDecoration(
                  hintText: "enter text here",
                ),
                controller: textController,
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if (docID == null) {
                        //check if note is empty
                        if (textController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please enter something!!')));
                        } else {
                          //add new note to db
                          firestoreService.addNote(textController.text);
                        }
                      } else {
                        if (textController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please enter something to update note!')));
                        } else {
                          firestoreService.updateNote(
                              docID, textController.text);
                        }
                      }

                      textController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Save'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('home page'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: openNoteBox,
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getNoteStream(),
            builder: (context, snapshot) {
              //check if snapshot has data
              if (snapshot.hasData) {
                List notesList = snapshot.data!.docs;

                //display in listview
                return ListView.builder(
                  itemCount: notesList.length,
                  itemBuilder: (context, index) {
                    //get individual doc
                    DocumentSnapshot document = notesList[index];
                    String docID = document.id;

                    //get note from doc
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String noteText = data['note'];

                    //display in list tile
                    return ListTile(
                      title: Text(noteText),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          //update button
                          IconButton(
                            onPressed: () => openNoteBox(docID: docID),
                            icon: const Icon(Icons.settings),
                          ),

                          //delete button
                          IconButton(
                            onPressed: () => firestoreService.deleteNote(docID),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return const Text("No notes");
              }
            }));
  }
}
