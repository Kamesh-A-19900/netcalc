import 'package:flutter/material.dart';

class NetCalScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const NetCalScaffold({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.blueGrey[900]),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(decoration: BoxDecoration(color: Colors.blueGrey[800]), child: Text("NetCal Menu", style: TextStyle(fontSize: 20))),
            ListTile(title: Text("Home"), onTap: () => Navigator.pushNamed(context, '/home')),
            ListTile(title: Text("TCP/UDP Analyzer"), onTap: () => Navigator.pushNamed(context, '/tcpudp')),
            ListTile(title: Text("IP Group Allocator"), onTap: () => Navigator.pushNamed(context, '/group')),
            ListTile(title: Text("Subnet Calculator"), onTap: () => Navigator.pushNamed(context, '/network-class')), 
          ],
        ),
      ),
      body: Center(child: body),
    );
  }
}
