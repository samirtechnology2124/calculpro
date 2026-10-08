import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(CalculatorPro());

class CalculatorPro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator Pro',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CalcScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 120, height: 120, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(28)), child: Icon(Icons.calculate_rounded, size: 70, color: Colors.black)),
        SizedBox(height: 20), Text("CALCULATOR PRO", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 40), CircularProgressIndicator(color: Colors.orange),
      ])),
    );
  }
}

class CalcScreen extends StatefulWidget {
  @override
  State<CalcScreen> createState() => _CalcScreenState();
}

class _CalcScreenState extends State<CalcScreen> {
  String input = "";
  String result = "0";
  List<String> history = [];
  bool scientific = false;

  void press(String v) {
    HapticFeedback.lightImpact();
    setState(() {
      if (v == "C") { input = ""; result = "0"; }
      else if (v == "=") { calculate(); }
      else if (v == "⌫") { if (input.isNotEmpty) input = input.substring(0, input.length - 1); }
      else if (v == "√") { input += "sqrt("; }
      else { input += v; }
    });
  }

  void calculate() {
    try {
      String f = input.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('π', '3.14159265359');
      var exp = Parser().parse(f);
      double e = exp.evaluate(EvaluationType.REAL, ContextModel());
      String r = e.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      result = r;
      if(input.isNotEmpty) history.insert(0, "$input = $result");
    } catch (_) { result = "Error"; }
  }

  // RESPONSIVE BUTTON
  Widget btn(String t, {Color? c, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.all(4),
        child: SizedBox(
          height: scientific ? 46 : 58, // smaller when scientific ON
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: c ?? Color(0xFF1E1E1E),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => press(t),
            child: Text(t, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 48,
        title: Row(children: [Icon(Icons.calculate, color: Colors.orange, size: 20), SizedBox(width:6), Text("Calculator Pro", style: TextStyle(fontSize: 16))]),
        actions: [
          IconButton(icon: Icon(scientific? Icons.science : Icons.science_outlined, color: Colors.orange, size: 20), onPressed: ()=> setState(()=> scientific =!scientific)),
          IconButton(icon: Icon(Icons.history, size: 20), onPressed: ()=> showModalBottomSheet(context: context, backgroundColor: Color(0xFF111111), builder: (c)=> ListView(children: history.map((e)=> ListTile(title: Text(e))).toList()))),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          // DISPLAY - Flexible so it shrinks when scientific is ON
          Expanded(
            flex: scientific ? 2 : 3,
            child: GestureDetector(
              onTap: (){ Clipboard.setData(ClipboardData(text: result)); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Copied!"))); },
              child: Container(width: double.infinity, padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10), alignment: Alignment.bottomRight, child: SingleChildScrollView(reverse: true, child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(input, style: TextStyle(fontSize: 24, color: Colors.white60), textAlign: TextAlign.right),
                SizedBox(height: 6),
                Text(result, style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
              ]))),
            ),
          ),
          Divider(color: Colors.white10, height: 1),
          // BUTTONS AREA - No overflow, scroll if needed
          Flexible(
            flex: scientific ? 5 : 4,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Column(children: [
                  if(scientific)...[
                    Row(children: [btn("sin("), btn("cos("), btn("tan("), btn("log("), btn("^")]),
                    Row(children: [btn("("), btn(")"), btn("π"), btn("√"), btn("e")]),
                    SizedBox(height: 4),
                  ],
                  Row(children: [btn("C", c: Color(0xFFFF3B5C)), btn("⌫", c: Color(0xFFE67E22)), btn("%", c: Color(0xFFE67E22)), btn("÷", c: Colors.orange)]),
                  Row(children: [btn("7"), btn("8"), btn("9"), btn("×", c: Colors.orange)]),
                  Row(children: [btn("4"), btn("5"), btn("6"), btn("-", c: Colors.orange)]),
                  Row(children: [btn("1"), btn("2"), btn("3"), btn("+", c: Colors.orange)]),
                  Row(children: [btn("0", flex: 2), btn("."), btn("=", c: Colors.green.shade600, flex: 2)]),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}