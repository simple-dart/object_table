import 'package:simple_dart_checkbox/simple_dart_checkbox.dart';
import 'package:simple_dart_table/simple_dart_table.dart';
import 'package:simple_dart_ui_core/simple_dart_ui_core.dart';

class ObjectTableRow<T> extends AbstractTableRow {
  late CellRenderer cellFactory;
  ObjectListAdapter<T> rowAdapter;
  Checkbox checkbox = Checkbox()..visible = false;
  final List<AbstractTableCell> _cells = <AbstractTableCell>[];
  late T _object;

  @override
  List<AbstractTableCell> get cells => _cells;

  @override
  List<dynamic> get rowData => cells.map((e) => e.value).toList();

  @override
  set rowData(List<dynamic> value) {
    throw UnsupportedError('rowData is read-only');
  }

  T get object => _object;

  set object(T value) {
    _object = value;
    final rowData = rowAdapter(value);
    for (var colNum = 0; colNum < rowData.length; colNum++) {
      createOrUpdateCell(colNum, rowData[colNum]);
    }
  }

  ObjectTableRow(this.rowAdapter, List<TableColumnDescr> newCols) : super(newCols) {
    cellFactory = CellRendererDefault();
    final cell = ComponentTableCell(checkbox);
    add(cell);
  }

  void createOrUpdateCell(int colNum, dynamic value) {
    final existCell = cells.length > colNum ? cells[colNum] : null;
    final columnDescr = columns.length > colNum ? columns[colNum] : TableColumnDescr();
    if (existCell == null) {
      final cell = cellFactory.createCellByType(columnDescr, value)
        ..value = value
        ..width = '${columnDescr.width}px';
      cells.add(cell);
      add(cell);
    } else {
      final isCompatibleCell = cellFactory.checkCellByType(existCell, value);
      if (isCompatibleCell) {
        existCell.value = value;
      } else {
        final newCell = cellFactory.createCellByType(columnDescr, value)
          ..value = value
          ..width = '${columnDescr.width}px';
        cells[colNum].remove();
        insert(colNum + 1, newCell);
        cells[colNum] = newCell;
      }
    }
  }
}
