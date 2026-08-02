import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReportGenerator {
  static Future<void> generateExcelReport({
    required String fileName,
    required String sheetName,
    required List<String> columns,
    required List<List<dynamic>> data,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel[sheetName];

    // Add headers
    for (var i = 0; i < columns.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(columns[i]);
    }

    // Add data
    for (var row = 0; row < data.length; row++) {
      for (var col = 0; col < data[row].length; col++) {
        final val = data[row][col];
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1)).value = 
            val is num ? DoubleCellValue(val.toDouble()) : TextCellValue(val.toString());
      }
    }

    final bytes = excel.save();
    if (bytes == null) return;

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName.xlsx');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], text: 'Report: $fileName');
  }
}
