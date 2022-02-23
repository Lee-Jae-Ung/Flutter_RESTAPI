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
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:http/http.dart' as http;


/*
Future<String> _downloadCsv() async {
  //const url = "https://projects.fivethirtyeight.com/soccer-api/international/spi_global_rankings_intl.csv";
  const url = "http://203.250.77.238:50001/manage/Status/RawData.csv";
  try {
    String csvRead = await http.read(Uri.parse(url));
    return csvRead;
  }
  catch(e) {
    //print('download error:$e');
    return '';
  }
}
*/
class SqliteTestModel {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    return await initDB();
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'RawData.db');

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

  Future<void> testUpdate(RawData item) async {
    var db = await database;

    await db.update(
        'Raws',
        item.toMap(),
        where: 'No = ?',
        whereArgs: [item.No]
    );
  }
}

void main() => runApp(MaterialApp(
  title: 'Navigator',
  home: testApp(),
)
);
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

List<double> dbarr = <double>[];
class testApp extends StatefulWidget {
  const testApp({Key? key}) : super(key: key);

  @override
  _testAppState createState() => _testAppState();
}

class _testAppState extends State<testApp> {


  @override
  Widget build(BuildContext context) {

    var _model = SqliteTestModel();
    //int i = 0;
    var temp;
    var list;


    print("build");

    return MaterialApp(

      title: 'FF',
      home: Scaffold(
        appBar: AppBar(
          title: Text('FDE'),
        ),
        body: Column(
          children: <Widget>[
            OutlinedButton(
                onPressed: () async {
                  String _result;
                  var list = await _model.Raws();

                  setState(() {
                    _result = '';

                    for (var item in list) {
                      _result += '${item.No} - ${item.Ch1}\n';
                    }
                  });
                  print("select");
                  },

                child: Text('SELECT')
            ),

            OutlinedButton(
                onPressed: () async {
                  const url = "http://203.250.77.238:50001/manage/Status/RawData.csv";
                  String csvRead = await http.read(Uri.parse(url));
                  var temp = csvRead.toString()
                      .split('\n');

                  print(temp.length);
                  int i;
                  for (i=0;i<(temp.length-1);i++) {
                    _model.testInsert(RawData(
                        No: i,
                        Ch1: double.parse(temp[i])
                    ));
                  }


                },

                child: Text('INSERT')
            ),
            OutlinedButton(
                onPressed: () async {
                  dbarr = <double>[];
                  const url = "http://203.250.77.238:50001/manage/Status/RawData.csv";
                  String csvRead = await http.read(Uri.parse(url),headers: {"Access-Control-Allow-Headers": "Access-Control-Allow-Origin, Accept"});
                  var temp = csvRead.toString()
                      .split('\n');


                  int i;
                  for (i=0;i<(temp.length-1);i++) {
                    dbarr.add(double.parse(temp[i]));
                  }
                  /*
                  int i;
                  for (i=0;i<(temp.length-1);i++) {
                    _model.testUpdate(RawData(
                        No: i,
                        Ch1: double.parse(temp[i])
                    ));
                  }

                   */
                  print(dbarr.length);

                  Navigator.push(context,
                      MaterialPageRoute<void>(builder: (BuildContext context) {
                        return ChartPage();
                      })
                  );


                },

                child: Text("UPDATE")
            ),



          ],


/*
              OutlinedButton(
                  onPressed: () async {
                    String _result;
                    var list = await _model.Raws();

                    setState(() {
                      _result = '';

                      for (var item in list) {
                        _result += '${item.No} - ${item.Ch1}\n';
                      }
                    });
                  },
                  child: Text('SELECT')
              ),

              OutlinedButton(
                  onPressed: () async {
                    FutureBuilder(
                        future: myFuture,
                        builder: (context, snapshot) {
                          temp = snapshot.data.toString()
                              .replaceAll('Ch1', '')
                              .split(',');
                          i=0;
                          for (String value in temp) {
                            _model.testUpdate(RawData(
                                No: i++,
                                Ch1: double.parse(value)
                            ));
                          }
                          return Text("zz");
                        });
                  },
                  child: Text('UPDATE')
              ),
*/

              /*
                list = _model.Raws();
                String _result = '';
                for(var item in list){
                  _result += '${item.No} , ${item.Ch1}\n';
                }
  */
              //print(_result);

          )
        ),
      );


  }
}


class ChartPage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text("Chart Page"),
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    child: CustomPaint(
                        size: Size(400, 200),
                        foregroundPainter: LineChart(
                            points: dbarr,
                            pointSize: 1.0,
                            // 점의 크기를 정합니다.
                            lineWidth: 1.0,
                            // 선의 굵기를 정합니다.
                            lineColor: Colors.purpleAccent,
                            // 선의 색을 정합니다.
                            pointColor: Colors.purpleAccent)), // 점의 색을 정합니다.
                  ),

                  RaisedButton(
                    child: Text('Go First Screen'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        )
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

class LineChart extends CustomPainter {
  List<double> points;
  double lineWidth;
  double pointSize;
  Color lineColor;
  Color pointColor;
  int maxValueIndex=0;
  int minValueIndex=0;
  double fontSize = 18.0;

  LineChart({required this.points, required this.pointSize, required this.lineWidth, required this.lineColor, required this.pointColor});

  @override
  void paint(Canvas canvas, Size size) {
    List<Offset> offsets = getCoordinates(points, size); // 점들이 그려질 좌표를 구합니다.

    drawText(canvas, offsets); // 텍스트를 그립니다. 최저값과 최고값 위아래에 적은 텍스트입니다.

    drawLines(canvas, size,  offsets); // 구한 좌표를 바탕으로 선을 그립니다.
    drawPoints(canvas, size, offsets); // 좌표에 따라 점을 그립니다.
  }

  void drawLines(Canvas canvas, Size size, List<Offset> offsets) {
    Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path path = Path();

    double dx = offsets[0].dx;
    double dy = offsets[0].dy;

    path.moveTo(dx, dy);
    offsets.map((offset) => path.lineTo(offset.dx , offset.dy)).toList();

    canvas.drawPath(path, paint);
  }

  void drawPoints(Canvas canvas, Size size, List<Offset> offsets) {
    Paint paint = Paint()
      ..color = pointColor
      ..strokeCap = StrokeCap.round
      ..strokeWidth = pointSize;

    canvas.drawPoints(PointMode.points, offsets, paint);
  }

  List<Offset> getCoordinates(List<double> points, Size size) {
    List<Offset> coordinates = [];

    double spacing = size.width / (points.length - 1); // 좌표를 일정 간격으로 벌리지 위한 값을 구합니다.
    double maxY = points.reduce(max); // 데이터 중 최소값을 구합니다.
    double minY = points.reduce(min); // 데이터 중 최대값을 구합니다.

    double bottomPadding = fontSize * 2; // 텍스트가 들어갈 패딩(아랫쪽)을 구합니다.
    double topPadding = bottomPadding * 2; // 텍스트가 들어갈 패딩(위쪽)을 구합니다.
    double h = size.height - topPadding; // 패딩을 제외한 화면의 높이를 구합니다.

    for (int index = 0; index < points.length; index++) {
      double x = spacing * index; // x축 좌표를 구합니다.
      double normalizedY = points[index] / maxY; // 정규화한다. 정규화란 [0 ~ 1] 사이가 나오게 값을 변경하는 것.
      double y = getYPos(h, bottomPadding, normalizedY); // Y축 좌표를 구합니다. 높이에 비례한 값입니다.

      Offset coord = Offset(x, y);
      coordinates.add(coord);

      findMaxIndex(points, index, maxY, minY); // 텍스트(최대값)를 적기 위해, 최대값의 인덱스를 구해놓습니다.
      findMinIndex(points, index, maxY, minY); // 텍스트(최소값)를 적기 위해, 최대값의 인덱스를 구해놓습니다.
    }

    return coordinates;
  }

  double getYPos(double h, double bottomPadding, double normalizedY) => (h + bottomPadding) - (normalizedY * h);


  void findMaxIndex(List<double> points, int index, double maxY, double minY) {
    if (maxY == points[index]) {
      maxValueIndex = index;
    }
  }

  void findMinIndex(List<double> points, int index, double maxY,double minY) {
    if (minY == points[index]) {
      minValueIndex = index;
    }
  }

  void drawText(Canvas canvas, List<Offset> offsets) {
    String maxValue = points.reduce(max).toString();
    String minValue = points.reduce(min).toString();

    drawTextValue(canvas, minValue, offsets[minValueIndex], false);
    drawTextValue(canvas, maxValue, offsets[maxValueIndex], true);
  }

  void drawTextValue(Canvas canvas, String text, Offset pos, bool textUpward) {
    TextSpan maxSpan = TextSpan(style: TextStyle(fontSize: fontSize, color: Colors.black, fontWeight: FontWeight.bold), text: text);
    TextPainter tp = TextPainter(text: maxSpan, textDirection: TextDirection.ltr);
    tp.layout();

    double y = textUpward ? -tp.height * 1.5  : tp.height * 0.5; // 텍스트의 방향을 고려해 y축 값을 보정해줍니다.
    double dx = pos.dx - tp.width / 2; // 텍스트의 위치를 고려해 x축 값을 보정해줍니다.
    double dy = pos.dy + y;

    Offset offset = Offset(dx, dy);

    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(LineChart oldDelegate) {
    return oldDelegate.points != points;
  }
}