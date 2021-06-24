import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'My Todo App',
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          scaffoldBackgroundColor: Colors.white.withOpacity(0),
        ),
        home: Stack(
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(),
              child: Image.asset(
                'images/sakura-haikei.jpeg',
                fit: BoxFit.cover,
              ),
            ),
            TodoListPage()
          ],
        ));
    // TodoListPage());
  }
}

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final textController = TextEditingController();
  // TodoListのデータ
  List<String> todoList = [];
  // 完了済みのタスク
  List<String> doneList = [];
  bool inputMode = false;

  // Shared Preferenceに値を保存されているデータを読み込んでセットする。
  _getPrefItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      todoList = prefs.getStringList('todoList') ?? [];
      doneList = prefs.getStringList('doneList') ?? [];
    });
  }

  // Shared Preferenceにデータを書き込む
  _setPrefTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todoList', todoList);
  }

  // Shared Preferenceにデータを書き込む
  _setPrefDoneList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('doneList', doneList);
  }

  @override
  void initState() {
    super.initState();
    _getPrefItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('リスト一覧'),
      ),
      body: listView(),
    );
  }

  Widget listView() {
    return ListView.builder(
        itemCount: todoList.length + doneList.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return addCard();
          } else if (index <= todoList.length) {
            return todoCard(index - 1);
          } else {
            return doneCard(index - todoList.length - 1);
          }
        });
  }

  Widget addCard() {
    if (inputMode) {
      return Card(
        color: Colors.amber[100],
        child: ListTile(
          title: TextField(
            autofocus: true,
            controller: textController,
            onSubmitted: (String value) {
              setState(() {
                todoList.insert(0, value);
                _setPrefTodoList();
                inputMode = false;
              });
              textController.clear();
            },
          ),
          trailing: GestureDetector(
            onTap: () {
              setState(() {
                inputMode = false;
              });
            },
            child: Icon(
              Icons.close,
              color: Colors.black87,
            ),
          ),
        ),
      );
    } else {
      return Card(
        color: Colors.amber[100],
        child: ListTile(
          title: Text("追加する"),
          leading: Icon(
            Icons.add,
            color: Colors.pinkAccent,
          ),
          onTap: () {
            setState(() {
              inputMode = true;
            });
          },
        ),
      );
    }
  }

  Widget todoCard(int todoIndex) {
    return Card(
      child: ListTile(
        tileColor: Colors.white,
        title: Text(todoList[todoIndex]),
        leading: GestureDetector(
          onTap: () {
            setState(() {
              doneList.insert(0, todoList[todoIndex]);
              _setPrefDoneList();
              todoList.remove(todoList[todoIndex]);
              _setPrefTodoList();
            });
          },
          child: Icon(
            Icons.check_box_outline_blank,
            color: Colors.pinkAccent,
          ),
        ),
        trailing: GestureDetector(
          onTap: () {
            setState(() {
              todoList.remove(todoList[todoIndex]);
              _setPrefTodoList();
            });
          },
          child: Icon(Icons.close),
        ),
      ),
    );
  }

  Widget doneCard(int doneIndex) {
    return Card(
      child: ListTile(
        tileColor: Colors.grey,
        title: Text(doneList[doneIndex]),
        leading: GestureDetector(
          onTap: () {
            setState(() {
              todoList.insert(0, doneList[doneIndex]);
              _setPrefTodoList();
              doneList.remove(doneList[doneIndex]);
              _setPrefDoneList();
            });
          },
          child: Icon(
            Icons.check_box_outlined,
            color: Colors.pinkAccent,
          ),
        ),
        trailing: GestureDetector(
          onTap: () {
            setState(() {
              doneList.remove(doneList[doneIndex]);
              _setPrefDoneList();
            });
          },
          child: Icon(Icons.close),
        ),
      ),
    );
  }
}
