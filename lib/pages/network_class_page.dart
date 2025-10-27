import 'package:flutter/material.dart';
import 'package:netcalc/server/ip_analyzer_wasm.dart';
import '../widgets/netcal_scaffold.dart';

class NetworkClassPage extends StatefulWidget {
  @override
  _NetworkClassPageState createState() => _NetworkClassPageState();
}

class _NetworkClassPageState extends State<NetworkClassPage> {
  final TextEditingController _ipController = TextEditingController();
  String _output = "Packet Details will appear here.";

  @override
  Widget build(BuildContext context) {
    return NetCalScaffold(
      title: "Subnet Calculator",
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Enter IPv4 Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(controller: _ipController, decoration: InputDecoration(border: OutlineInputBorder())),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async{
                try{
                  final input = _ipController.text.replaceAll(RegExp(r'\s+'), '').trim();
                  if (input.isEmpty ) {
                    setState(() {
                      _output = "Please enter a valid IP and CIDR Notation (xxx:xxx:xxx:xxx/xx).";
                    });
                    return;
                  }
                  final result = await IpAnalyzerWasm.analyze(input);

                  setState(() {
                    _output = result;
                  });
                } catch (e) {
                  setState(() {
                    _output = "Error calling WASM: $e";
                  });
                }
              },                  
              child: Text("Identify Class")
            ),
            SizedBox(height: 20),
            Text(_output),
          ],
        ),
      ),
    );
  }
}
