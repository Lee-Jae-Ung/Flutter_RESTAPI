/*
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
*/
/*
void main() => runApp(WithNavigator());

class WithNavigator extends StatefulWidget {
  WithNavigator({Key? key}) : super(key: key);
  @override
  _WithNavigatorState createState() => _WithNavigatorState();
}
class _WithNavigatorState extends State<WithNavigator> {
  @override
  void initState() {
    super.initState();
    _downloadCsv();
  }
  Future<void> _downloadCsv() async {
    final url = "https://projects.fivethirtyeight.com/soccer-api/international/spi_global_rankings_intl.csv";
    try {
      var csvRead = await http.read(Uri.parse(url));
      Navigator.push( context, MaterialPageRoute(builder: (context) => DataTablePage(csvString: csvRead)),
      );
    }
    catch(e) {
      print('download error:$e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('DataTable Demo'),
        ),
        body: Center(
          child: Text('loading...', style: TextStyle(fontSize: 50.0),),
        )
    );
  }
}
class DataTablePage extends StatefulWidget {
  final csvString;
  DataTablePage({Key? key, @required this.csvString }) : super(key: key);
  @override
  _DataTablePageState createState() => _DataTablePageState();
}
class _DataTablePageState extends State<DataTablePage> {
  List<String>? csvRows;
  List<String>? csvHeadingRow;
  @override
  void initState() {
    super.initState();
    List<String> csvSplit = widget.csvString.split('\n');
    csvHeadingRow = csvSplit[0].split(',');
    csvSplit.removeAt(0); csvRows = csvSplit;
  }
  void _dataColumnSort(int columnIndex, bool ascending) {
    print('_dataColumnSort() $columnIndex, $ascending');
  }
  List<DataColumn> _getColumns() {
    List<DataColumn> dataColumn = [];
    for (var i in csvHeadingRow!) {
      if (i == 'rank') {
        dataColumn.add(DataColumn(label: Text(i), tooltip: i, numeric: true, onSort: _dataColumnSort));
      }
      else {
        dataColumn.add(DataColumn(label: Text(i), tooltip: i));
      }
    }
    return dataColumn;
  }
  List<DataRow> _getRows() {
    List<DataRow> dataRow = [];
    for (var i=0; i<csvRows!.length-1; i++) {
      var csvDataCells = csvRows![i].split(',');
      List<DataCell> cells = [];
      for(var j=0; j<csvDataCells.length; j++) {
        cells.add(DataCell(Text(csvDataCells[j])));
      }
      dataRow.add(DataRow(cells: cells));
    }
    return dataRow;
  }
  Widget _getDataTable() {
    return DataTable( horizontalMargin: 12.0, columnSpacing: 28.0, columns: _getColumns(), rows: _getRows(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar( title: Text('DataTable Demo'),),
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: _getDataTable(),
          ),
        )
    );
  }
}

*/

//csv불러와서 문자열 배열로 저장됨 double형으로 변환 실패
/*
void main() => runApp(WithNavigator());


Future<String> _downloadCsv() async {
  //const url = "https://projects.fivethirtyeight.com/soccer-api/international/spi_global_rankings_intl.csv";
  final url = "http://203.250.77.238:50001/manage/Status/RawData.csv";
  try {
    String csvRead = await http.read(Uri.parse(url));
    return csvRead;
  }
  catch(e) {
    //print('download error:$e');
    return '';
  }
}

class WithNavigator extends StatefulWidget {
  WithNavigator({Key? key}) : super(key: key);
  @override
  _WithNavigatorState createState() => _WithNavigatorState();
}

class _WithNavigatorState extends State<WithNavigator> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> temp;
    List<double> abc = List.empty();
    Future<String> a = _downloadCsv();
    print("build");

    return MaterialApp(

      title: 'FF',
      home: Scaffold(
        appBar: AppBar(
          title: Text('FDE'),
        ),
        body: Center(

            child : FutureBuilder(
              future: a,
              builder: (context,snapshot){
                temp = snapshot.data.toString().replaceAll('Ch1','').split(',');


                for(int i=0;i<1000;i++){
                  abc.add(double.parse(temp[i]));
                }

                return Text("zz");
              },
            ),
        ),
      ),
    );
  }
}
*/

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;



Future<String> fetchPost() async {
  final response =
  await http.get(Uri.parse('http://203.250.77.238:50001/manage/Status/RawData.csv'));
  if (response.statusCode == 200) {
    // 만약 서버로의 요청이 성공하면, JSON을 파싱합니다.
    return response.body;
  } else {
    // 만약 요청이 실패하면, 에러를 던집니다.
    throw Exception('Failed to load post');
  }
}

class SqliteTestModel {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    return await initDB();
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'ttttt.db');

    return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade
    );
  }
  FutureOr<void> _onCreate(Database db, int version) {
    String sql = '''
  CREATE TABLE Raws(
    No INTEGER PRIMARY KEY,
    Ch1 FLOAT)
  ''';

    db.execute(sql);
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) {}

  Future<List<RawData>> Raws() async {
    // 데이터베이스 reference를 얻습니다.
    var db = await database;

    // 모든 Dog를 얻기 위해 테이블에 질의합니다.
    final List<Map<String, dynamic>> maps = await db.query('Raws');

    // List<Map<String, dynamic>를 List<Dog>으로 변환합니다.
    return List.generate(maps.length, (i) {
      return RawData(
        No: maps[i]['No'] as int,
        Ch1: maps[i]['Ch1'] as double,

      );
    });
  }

  Future<void> testInsert(RawData item) async {
    var db = await database;

    await db.insert(
        'Raws',
        item.toMap()
    );
  }
}

void main() => runApp(testApp());
  //WidgetsFlutterBinding.ensureInitialized();


/*
  final database = openDatabase(
    // 데이터베이스 경로를 지정합니다. 참고: `path` 패키지의 `join` 함수를 사용하는 것이
    // 각 플랫폼 별로 경로가 제대로 생성됐는지 보장할 수 있는 가장 좋은 방법입니다.
    await getDatabasesPath() + 'RawData.db',
    // 데이터베이스가 처음 생성될 때, dog를 저장하기 위한 테이블을 생성합니다.

    // 버전을 설정하세요. onCreate 함수에서 수행되며 데이터베이스 업그레이드와 다운그레이드를
    // 수행하기 위한 경로를 제공합니다.
    version: 1,
  );
*/
  /*
  var _model = SqliteTestModel();

  var list = await _model.Raws();
  String _result = '';
  for(var item in list){
    _result += '${item.No} , ${item.Ch1}\n';
  }
  print("zz");
  print(_result);
*/


class testApp extends StatefulWidget {
  const testApp({Key? key}) : super(key: key);

  @override
  _testAppState createState() => _testAppState();
}

class _testAppState extends State<testApp>{
  Future<String>? myFuture;

  @override
  void initState(){
    myFuture = fetchPost();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    var _model = SqliteTestModel();
    int i=0;
    var temp;
    var list;

    print("build");

    return MaterialApp(

      title: 'FF',
      home: Scaffold(
        appBar: AppBar(
          title: Text('FDE'),
        ),
        body: Center(

          child : FutureBuilder<String>(
            future: myFuture,
            builder: (context,snapshot){
              temp = snapshot.data.toString().replaceAll('Ch1','').split(',');
/*
              for(String value in temp){
                _model.testInsert(RawData(
                No: i++,
                Ch1: double.parse(value)
                ));
              }
              */


              list = _model.Raws();
              String _result = '';
              for(var item in list){
                _result += '${item.No} , ${item.Ch1}\n';
              }

              print(_result);



              return Text("zz");
            },
          ),
        ),
      ),
    );
  }
}




class RawData {
  final int No;
  final double Ch1;

  RawData({required this.No, required this.Ch1});

  Map<String, dynamic> toMap() {
    return {
      'No': No,
      'Ch1': Ch1,
    };
  }

  // 각 dog 정보를 보기 쉽도록 print 문을 사용하여 toString을 구현하세요
  @override
  String toString() {
    return 'RawData{No: $No, Ch1: $Ch1}';
  }


}