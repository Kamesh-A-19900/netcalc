import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:netcalc/server/ip_allocator_wasm.dart';
import '../widgets/netcal_scaffold.dart';
import '../utils/excel_exporter.dart';


class GroupAllocatorPage extends StatefulWidget {
  const GroupAllocatorPage({Key? key}) : super(key: key);

  @override
  State<GroupAllocatorPage> createState() => _GroupAllocatorPageState();
}

class _GroupAllocatorPageState extends State<GroupAllocatorPage> {
  final TextEditingController _startIpController = TextEditingController();
  final List<GroupData> _groups = [];
  List<Map<String, dynamic>> _allocations = [];

  void _addGroup() {
    setState(() {
      _groups.add(GroupData());
    });
  }

  void _removeGroup(int index) {
    setState(() {
      _groups.removeAt(index);
    });
  }

  Future<void> _allocate() async {
    final cidr = _startIpController.text.trim();
    if (cidr.isEmpty || _groups.isEmpty) return;

    final inputMap = {
      "Groups": _groups.length,
      "Group": List.generate(_groups.length, (i) => i),
      "Person": _groups.map((g) => int.tryParse(g.personController.text) ?? 0).toList(),
      "ip": _groups.map((g) => int.tryParse(g.ipController.text) ?? 0).toList(),
    };

    final jsonInput = jsonEncode(inputMap);
    final resultStr = await IpAllocatorWasm.allocate(cidr, jsonInput);

    dynamic parsed;
    try {
      parsed = jsonDecode(resultStr);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultStr)));
      return;
    }

    if (parsed is List) {
      setState(() {
        _allocations = List<Map<String, dynamic>>.from(parsed);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(resultStr)));
    }
  }

  String buildJsonInput(List<GroupData> groups) {
    final groupIds = <int>[];
    final persons = <int>[];
    final ips = <int>[];

    for (int i = 0; i < groups.length; i++) {
      groupIds.add(i);
      final p = int.tryParse(groups[i].personController.text) ?? 0;
      final ip = int.tryParse(groups[i].ipController.text) ?? 0;
      persons.add(p);
      ips.add(ip);
    }

    final map = {
      "Groups": groups.length,
      "Group": groupIds,
      "Person": persons,
      "ip": ips,
    };
    return jsonEncode(map);
  }

  Future<void> onAllocatePressed(BuildContext context, String cidr, List<GroupData> groups) async {
    if (cidr.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter starting CIDR')));
      return;
    }
    final jsonInput = buildJsonInput(groups);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    try {
      final resultJsonString = await IpAllocatorWasm.allocate(cidr, jsonInput);
      Navigator.of(context).pop(); // close spinner

      // resultJsonString is a JSON array or an error object string
      dynamic parsed;
      try {
        parsed = jsonDecode(resultJsonString);
      } catch (e) {
        // not valid JSON — show raw
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Allocation Result'),
            content: SingleChildScrollView(child: Text(resultJsonString)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
          ),
        );
        return;
      }

      // If parsed is a list, show table-like output
      if (parsed is List) {
        final rows = StringBuffer();
        for (var item in parsed) {
          rows.writeln(item.toString());
        }
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Allocation Result'),
            content: SingleChildScrollView(child: Text(rows.toString())),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
          ),
        );
      } else {
        // Error object
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Allocation Result'),
            content: SingleChildScrollView(child: Text(resultJsonString)),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // close spinner
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Allocation failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NetCalScaffold(
      title: "IP Group Allocator",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Starting IP Address",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _startIpController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                hintText: "e.g. 192.168.1.0/24",
              ),
            ),
            const SizedBox(height: 20),

            // --- Dynamic Groups ---
            ..._groups.asMap().entries.map((entry) {
              final index = entry.key;
              final group = entry.value;
              return _buildGroupCard(index, group);
            }),

            const SizedBox(height: 15),

            // --- Add Group Button ---
            Center(
              child: ElevatedButton.icon(
                onPressed: _addGroup,
                icon: const Icon(Icons.add),
                label: const Text("Add Group"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Allocate Button ---
            Center(
              child: ElevatedButton(
                onPressed: _allocate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Allocate IPs", style: TextStyle(fontSize: 16)),
              ),
            ),

            // --- Allocation Table ---
            if (_allocations.isNotEmpty) ...[
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Allocation Table",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => downloadIpAllocationExcel(jsonEncode(_allocations)),
                    icon: const Icon(Icons.download),
                    label: const Text("Download Excel"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ✅ Scrollable DataTable with height constraint
              SizedBox(
                height: 400,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Group')),
                        DataColumn(label: Text('PersonID')),
                        DataColumn(label: Text('Start IP')),
                        DataColumn(label: Text('End IP')),
                        DataColumn(label: Text('Allocated IPs')),
                      ],
                      rows: _allocations.map((row) {
                        return DataRow(
                          cells: [
                            DataCell(Text(row['Group'].toString())),
                            DataCell(Text(row['PersonID'].toString())),
                            DataCell(Text(row['StartIP'].toString())),
                            DataCell(Text(row['EndIP'].toString())),
                            DataCell(Text(row['AllocatedIPs'].toString())),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(int index, GroupData group) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Group Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Group ${index + 1}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.primary)),
                IconButton(
                  onPressed: () => _removeGroup(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // --- Input Fields ---
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: group.personController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Number of Persons",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: group.ipController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "IPs per Person",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GroupData {
  final TextEditingController personController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
}
