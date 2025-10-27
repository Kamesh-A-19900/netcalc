import 'package:flutter/material.dart';
import '../widgets/netcal_scaffold.dart';
import '../server/tcp_udp_wasm.dart'; // WASM helper


class TcpUdpAnalyzerPage extends StatefulWidget {
  @override
  _TcpUdpAnalyzerPageState createState() => _TcpUdpAnalyzerPageState();
}

class _TcpUdpAnalyzerPageState extends State<TcpUdpAnalyzerPage> {
  final TextEditingController _headerController = TextEditingController();
  String _output = "Packet Details will appear here.";

  @override
  Widget build(BuildContext context) {
    return NetCalScaffold(
      title: "TCP/UDP Header Analyzer",
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Enter TCP or UDP Header",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _headerController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "e.g. 4500003c1c4640004006b1e6c0a80001c0a800c7",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final input = _headerController.text
                      .replaceAll(RegExp(r'\s+'), '')
                      .trim();

                  if (input.isEmpty || input.length < 16) {
                    setState(() {
                      _output = "Please enter a valid TCP/UDP header (at least 16 hex chars).";
                    });
                    return;
                  }

                  // Await the WASM analyzer (initializes module if needed)
                  final result = await TcpUdpWasm.analyze(input);

                  setState(() {
                    _output = result;
                  });
                } catch (e) {
                  setState(() {
                    _output = "Error calling WASM: $e";
                  });
                }
              },
              child: const Text("Analyze Header"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  _output,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
