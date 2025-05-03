import 'package:flutter/material.dart';
import '../Model/Note.dart';
import '../Database Helper/NoteDatabaseHelper.dart';
import 'NoteDetailScreen.dart';
import 'NoteForm.dart';
import 'NoteItem.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  List<Note> notes = [];
  bool isGridView = false;
  int? _selectedPriorityFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes({int? priority}) async {
    List<Note> loadedNotes;
    if (priority != null) {
      loadedNotes = await NoteDatabaseHelper.instance.getNotesByPriority(priority);
    } else if (_searchQuery.isNotEmpty) {
      loadedNotes = await NoteDatabaseHelper.instance.searchNotes(_searchQuery);
    } else {
      loadedNotes = await NoteDatabaseHelper.instance.getAllNotes();
    }
    setState(() {
      notes = loadedNotes;
    });
  }

  void _navigateToNoteDetail(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
    ).then((_) => _loadNotes(priority: _selectedPriorityFilter));
  }

  void _navigateToNoteForm({Note? note}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteForm(note: note)),
    ).then((_) => _loadNotes(priority: _selectedPriorityFilter));
  }

  Future<void> _deleteNote(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn xóa ghi chú này?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Xóa'),
              onPressed: () async {
                await NoteDatabaseHelper.instance.deleteNote(id);
                _loadNotes(priority: _selectedPriorityFilter);
                Navigator.of(context).pop();
              },
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
        title: Text('Ghi Chú'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _loadNotes(priority: _selectedPriorityFilter),
          ),
          IconButton(
            icon: Icon(isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                isGridView = !isGridView;
              });
            },
          ),
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() {
                _selectedPriorityFilter = value;
              });
              _loadNotes(priority: value);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: null,
                child: Text('Tất cả'),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Ưu tiên thấp'),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text('Ưu tiên trung bình'),
              ),
              const PopupMenuItem<int>(
                value: 3,
                child: Text('Ưu tiên cao'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _loadNotes();
              },
              decoration: InputDecoration(
                labelText: 'Tìm kiếm',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: notes.isEmpty
                ? Center(child: Text('Không có ghi chú nào.'))
                : isGridView
                ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              padding: const EdgeInsets.all(8.0),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteItem(
                  note: note,
                  onTap: () => _navigateToNoteDetail(note),
                  onEdit: () => _navigateToNoteForm(note: note),
                  onDelete: () => _deleteNote(note.id!),
                );
              },
            )
                : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteItem(
                  note: note,
                  onTap: () => _navigateToNoteDetail(note),
                  onEdit: () => _navigateToNoteForm(note: note),
                  onDelete: () => _deleteNote(note.id!),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToNoteForm,
        child: Icon(Icons.add),
      ),
    );
  }
}