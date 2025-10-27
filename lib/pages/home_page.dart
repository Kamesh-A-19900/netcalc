import 'package:flutter/material.dart';
import '../widgets/netcal_scaffold.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NetCalScaffold(
      title: "NetCal Home",
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Welcome to NetCal",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Access all networking tools from one place: TCP/UDP analyzer, Subnet calculator, IP group allocator, Network class identifier, and visualization.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                FeatureCard(
                  title: "TCP/UDP Analyzer",
                  description: "Analyze packet headers and extract details.",
                  route: '/tcpudp',
                ),
                FeatureCard(
                  title: "IP Group Allocator",
                  description: "Allocate IPs to multiple groups and export Excel.",
                  route: '/group',
                ),
                FeatureCard(
                  title: "Subnet Calculator",
                  description: "Identify class, private/public, default mask.",
                  route: '/network-class',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String route;

  const FeatureCard({required this.title, required this.description, required this.route});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        color: Colors.blueGrey[800],
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 280,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 10),
              Text(description, style: TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
