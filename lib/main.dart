import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/tcp_udp_page.dart';
import 'pages/group_allocator_page.dart';
import 'pages/network_class_page.dart';
import 'pages/landing_page.dart';

void main() {
  runApp(NetCalApp());
}

class NetCalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NetCal',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => NetCalLandingPage(),
        '/home': (context) => HomePage(),
        '/tcpudp': (context) => TcpUdpAnalyzerPage(),
        '/group': (context) => GroupAllocatorPage(),
        '/network-class': (context) => NetworkClassPage(),
      },
    );
  }
}
