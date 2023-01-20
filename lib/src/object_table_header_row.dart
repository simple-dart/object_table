import 'package:simple_dart_checkbox/simple_dart_checkbox.dart';
import 'package:simple_dart_table/simple_dart_table.dart';

class ObjectTableHeaderRow extends TableRow {
  Checkbox checkbox = Checkbox()..visible = false;

  ObjectTableHeaderRow(List<TableColumnDescr> newCols) : super(newCols) {
    final cell = ComponentTableCell(checkbox);
    add(cell);
    for (final columnDescr in newCols) {
      final cell = ColumnHeaderCell(columnDescr);
      cells.add(cell);
      add(cell);
    }
  }
}
