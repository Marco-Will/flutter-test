import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0x3C201717),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final today = DateTime.now();

  final controller = PageController(initialPage: 0 );
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: PageView(
        controller: controller,
        reverse: true,
        children: const [
            DetailPage(headline : 'Heute', daysInPast: 0),
            DetailPage(headline: 'Gestern', daysInPast: 1),
            DetailPage(headline: 'Vorgestern', daysInPast: 2),

        ],)
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.headline,required this.daysInPast}) : super(key: key);

  final String headline;
  final int daysInPast;
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {


  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 90, 0, 12),
      child: Column (children:  [
        Text(widget.headline, style: const TextStyle(fontSize: 25, color: Colors.amber)),
        TrackingElement (color: const Color(0xFF51EEA7), iconData: Icons.directions_run, unit: 'm', max:5000, daysInPast:widget.daysInPast ,),
        TrackingElement (color: const Color(0xFF14BDE0), iconData: Icons.water_damage_sharp, unit: 'ml', max: 3000, daysInPast:widget.daysInPast ,),
        TrackingElement (color: const Color(0xFFEE5F8D), iconData: Icons.fastfood_outlined, unit: 'kcal', max: 1800,daysInPast:widget.daysInPast,),
      ],),
    );
  }
}


class TrackingElement extends StatefulWidget {
  const TrackingElement({Key? key, required this.color, required this.iconData,required this.daysInPast, required this.unit, required this.max}) : super(key: key);

  final String unit;
  final double max;
  final Color color;
  final IconData iconData;
  final int daysInPast;
  @override
  State<TrackingElement> createState() => _TrackingElementState();
}

class _TrackingElementState extends State<TrackingElement> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int _counter = 0;
  double _progress = 0;
  var now = DateTime.now();
  String _storageKey = '';

  void _incrementCounter() async{
    setState(() {
      if(widget.max > _counter){
        _counter += 200;
        _progress = _counter / widget.max;
      }
    });
   (await _prefs).setInt(_storageKey, _counter);
  }

  @override
  void initState(){
    super.initState();
     _storageKey = '${now.year}-${now.month}-${now.day - widget.daysInPast}_${widget.unit}';
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();

    _prefs.then( (prefs){
      setState(() {
        _counter = prefs.getInt(_storageKey) ?? 0 ;
        _progress = _counter / widget.max;
      });
    });
  }
  Future<void> _deleteSavedCounterValue() async {
    final prefs = await _prefs;
    prefs.remove(_storageKey);
    setState(() {
      _counter = 0;
      _progress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _incrementCounter ,
      child:Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 32, 32, 12),
            child: Row(children: <Widget> [
              Icon(widget.iconData, color:  const Color(0x95FCFCFC), size: 60,),
              Text(
                '$_counter  / ${widget.max} ${widget.unit}',
                style: const TextStyle(color: Colors.white, fontSize: 25),
              ),
            ],)
        ),
        LinearProgressIndicator(
          value: _progress,
          color: widget.color,
          backgroundColor: const Color(0x95FCFCFC),
          minHeight: 10,),
        Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 32, 0, 0),
            child: Column(children: <Widget> [
              FloatingActionButton(onPressed: _deleteSavedCounterValue, mini: true, backgroundColor: Color(0x95FCFCFC),
                  child: const Icon(Icons.delete, color: Colors.black,), )
            ],)
        ),

      ],
    ) ,);
  }
}

