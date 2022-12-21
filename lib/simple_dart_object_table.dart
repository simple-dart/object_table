import 'dart:async';

import 'package:simple_dart_checkbox/simple_dart_checkbox.dart';
import 'package:simple_dart_table/simple_dart_table.dart';

typedef ObjectTableRowAdapter<T> = List<dynamic> Function(T object);

class ObjectTableSelectEvent<T> {
  ObjectTableSelectEvent(this.object, {this.selected = false});

  final T object;
  bool selected = false;
}

class ObjectTable<T> extends Table {
  ObjectTable(this.objectRowAdapter, {selectable = false}) {
    _selectable = selectable;
    if (_selectable) {
      final cell = LabelTableCell('')..width = '40px';
      headersRow.cells.add(cell);
      headersRow.add(cell);
    }
  }

  List<T> objectList = <T>[];
  bool _selectable = false;

  late ObjectTableRowAdapter<T> objectRowAdapter;

  final StreamController<ObjectTableSelectEvent<T>> _onSelect = StreamController<ObjectTableSelectEvent<T>>.broadcast();

  TableRow createObjectRow(T object) {
    objectList.add(object);
    final rowData = objectRowAdapter(object)..add(object);
    final newRow = super.createRow(rowData);
    if (_selectable) {
      final checkboxField = Checkbox()
        ..width = '40px'
        ..onValueChange.listen((event) {
          _onCheckBoxSelect(ObjectTableSelectEvent(object, selected: event.newValue));
        });
      final cell = ComponentTableCell(checkboxField);
      newRow.insert(0, cell);
    }
    return newRow;
  }

  void _onCheckBoxSelect(ObjectTableSelectEvent<T> object) {
    _onSelect.sink.add(object);
  }

  Stream<ObjectTableSelectEvent<T>> get onSelect => _onSelect.stream;

  void dispose() {
    _onSelect.close();
  }

  List<T> getSelected() {
    final ret = <T>[];
    for (var i = 0; i < objectList.length; i++) {
      final row = rows[i];
      final obj = objectList[i];
      final checkBoxCell = row.children[0];
      if (checkBoxCell is ComponentTableCell) {
        final checkBox = checkBoxCell.children[0];
        if (checkBox is Checkbox) {
          if (checkBox.value) {
            ret.add(obj);
          }
        }
      }
    }
    return ret;
  }

  @override
  void clear() {
    super.clear();
    objectList.clear();
  }

  @override
  void sortData({int columnIndex = 0, bool desc = false}) {
    final rowData = <List<dynamic>>[];
    for (final row in rows) {
      rowData.add(row.data);
    }
    if (desc) {
      rowData.sort((a, b) {
        final data1 = a[columnIndex];
        final data2 = b[columnIndex];
        return compareDynamics(data2, data1);
      });
    } else {
      rowData.sort((a, b) {
        final data1 = a[columnIndex];
        final data2 = b[columnIndex];
        return compareDynamics(data1, data2);
      });
    }
    clear();
    rowData.forEach((row) {
      createObjectRow(row.last);
    });
  }
}