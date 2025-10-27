import 'dart:convert';
import 'dart:html' as html;
import 'package:excel/excel.dart';

/// Converts IP allocation JSON into a downloadable Excel file.
void downloadIpAllocationExcel(String jsonStr) {
  dynamic data;
  try {
    data = jsonDecode(jsonStr);
  } catch (_) {
    print('❌ Invalid JSON for Excel export');
    return;
  }

  if (data is! List || data.isEmpty) {
    print('⚠️ No allocation data to export.');
    return;
  }

  print('✅ Exporting ${data.length} rows to Excel');

  final excel = Excel.createExcel();
  final sheetName = 'Allocations';

  // Make sure the sheet is selected (important on web)
  final sheet = excel[sheetName];
  excel.setDefaultSheet(sheetName);

  // Header row
  sheet.appendRow([
    TextCellValue('Group'),
    TextCellValue('PersonID'),
    TextCellValue('StartIP'),
    TextCellValue('EndIP'),
    TextCellValue('AllocatedIPs'),
  ]);

  // Data rows
  for (final item in data) {
    if (item is Map) {
      sheet.appendRow([
        TextCellValue(item['Group']?.toString() ?? ''),
        TextCellValue(item['PersonID']?.toString() ?? ''),
        TextCellValue(item['StartIP']?.toString() ?? ''),
        TextCellValue(item['EndIP']?.toString() ?? ''),
        TextCellValue(item['AllocatedIPs']?.toString() ?? ''),
      ]);
    }
  }

  // Ensure workbook knows which sheet to export
  excel.setDefaultSheet(sheetName);

  final bytes = excel.encode();
  if (bytes == null) {
    print('⚠️ Excel encode() returned null.');
    return;
  }

  // Trigger browser download
  final blob = html.Blob(
    [bytes],
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = 'ip_allocations.xlsx'
    ..click();
  html.Url.revokeObjectUrl(url);
}
