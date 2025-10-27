import 'package:flutter/material.dart';
import '../widgets/section_widget.dart';

class NetCalLandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 100, horizontal: 50),
              color: Colors.blueGrey[900],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("NetCal", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 20),
                  Text(
                    "Your all-in-one Network Calculator & Visualizer.\nDecode packets, calculate subnets, allocate IPs, and visualize networks easily.",
                    style: TextStyle(fontSize: 20, color: Colors.white70),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/tcpudp'),
                    child: Text("Get Started"),
                  ),
                  SizedBox(height: 50),
                  Image.asset("../assets/images/network_hero.png", height: 300, fit: BoxFit.contain),
                ],
              ),
            ),

            SectionWidget(
              title: "TCP/UDP Header Analyzer",
              description: "Decode and visualize TCP/UDP packet headers quickly.",
              imageUrl: "../assets/images/tcp_udp.jpg",
              reverseLayout: false,
            ),
            SectionWidget(
              title: "IP Group Allocator",
              description: "Allocate IP ranges to groups and export Excel reports.",
              imageUrl: "../assets/images/ip_group.png",
              reverseLayout: false,
            ),
            SectionWidget(
              title: "Subnet Calculator",
              description: "Finds block of IP address, Usable hosts, Broadcast address",
              imageUrl: "../assets/images/subnet.jpg",
              reverseLayout: false,
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 80, horizontal: 50),
              color: Colors.blueGrey[800],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Ready to Try NetCal?", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 20),
                  Text("Host it yourself on GitHub Pages or explore it online!",
                      style: TextStyle(fontSize: 18, color: Colors.white70), textAlign: TextAlign.center),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/tcpudp'),
                    child: Text("Start Using NetCal"),
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20), textStyle: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
