import 'package:flutter/material.dart';
import 'package:notodo/model/nodo_item.dart';
import 'package:notodo/util/database_client.dart';
import 'package:notodo/util/date_formatter.dart';

class NoToDo extends StatefulWidget {
  @override
  _NoToDoState createState() => _NoToDoState();
}

class _NoToDoState extends State<NoToDo> {
  final _textEditingController = TextEditingController();
  var db = DatabaseHelper();
  final List<NoDoItem> _itemList = <NoDoItem>[];

  void _handleSubmit(String text) async {
    _textEditingController.clear();
    NoDoItem noDoItem = new NoDoItem(text, dateFormatted());
    int savedItemId = await db.saveItem(noDoItem);
    print("Item id is $savedItemId");
    NoDoItem addedItem = await db.getItem(savedItemId);

    setState(() {
      _itemList.insert(0, addedItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: _itemList.length,
              itemBuilder: (context, int index) {
                return Card(
                  color: Colors.white10,
                  child: ListTile(
                    title: _itemList[index],
                    onLongPress: () => _updateItem(_itemList[index], index),
                    trailing: new Listener(
                      key: new Key(_itemList[index].itemName),
                      child: Icon(Icons.remove_circle, color: Colors.redAccent),
                      onPointerDown: (pointerEvent) =>
                          _deleteNoDo(_itemList[index].id, index),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: _showFormDialog,
        tooltip: "Add Item",
        child: ListTile(
          title: Icon(Icons.add),
        ),
      ),
    );
  }

  void _deleteNoDo(int id, int index) async {
    await db.deleteItem(id);
    setState(() {
      _itemList.removeAt(index);
    });
  }
  @override
  void initState() {
    super.initState();
    _readNoDoList();
  }

  _readNoDoList() async {
    List items = await db.getItems();
    items.forEach((item) {
      setState(() {
        _itemList.add((NoDoItem.map(item)));
      });
    });
  }

  void _showFormDialog() {
    var alert = AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: "Item",
                  hintText: "Eg. don't buy stuff",
                  icon: Icon(Icons.note_add)),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            _handleSubmit(_textEditingController.text);
            _textEditingController.clear();
            Navigator.pop(context);
          },
          child: Text("Save"),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        )
      ],
    );
    showDialog(context: context, builder: (context) => alert);
  }

  _updateItem(NoDoItem item, int index) {
    var alert = AlertDialog(
      title: Text("Update Item"),
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                  labelText: "Item",
                  hintText: "Eg. Don't buy stuff",
                  icon: Icon(Icons.update)
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () async {
              NoDoItem newItemUpdated = NoDoItem.fromMap({
                "itemName": _textEditingController.text,
                "dateCreated": dateFormatted(),
                "id": item.id
              });
              _handleSubmittedUpdate(index
                  , item);
              await db.updateItem(newItemUpdated);
              setState(() {
                _readNoDoList();
              });
              Navigator.pop(context);
            },
            child: Text("Update")
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
              "Cancel"
          ),
        )
      ],
    );
    showDialog(context: context, builder: (_) => alert);
  }

  void _handleSubmittedUpdate(int index, NoDoItem item) {
    setState(() {
      _itemList.removeWhere((element) {
        _itemList[index].itemName == item.itemName;
      });
    });
  }
}
