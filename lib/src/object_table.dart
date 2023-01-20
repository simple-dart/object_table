import 'dart:async';

import 'package:simple_dart_table/simple_dart_table.dart';
import 'package:simple_dart_ui_core/simple_dart_ui_core.dart';

import '../simple_dart_object_table.dart';

typedef ObjectTableRowAdapter<T> = List<dynamic> Function(T object);

class ObjectTableSelectEvent<T> {
  ObjectTableSelectEvent(this.object, {this.selected = false});

  final T object;
  bool selected = false;
}

class ObjectTable<T> extends Table {
  late ObjectTableRowAdapter<T> objectRowAdapter;
  final StreamController<ObjectTableSelectEvent<T>> _onSelectController =
      StreamController<ObjectTableSelectEvent<T>>.broadcast();

  bool _checkboxVisible = false;

  ObjectTable(this.objectRowAdapter);

  @override
  void initColumns(List<TableColumnDescr> columns) {
    this.columns = columns;
    headersRow = ObjectTableHeaderRow(columns)
      ..addCssClass('Header')
      ..checkbox.onValueChange.listen(headerCheckboxValueChange);
    for (var i = 0; i < columns.length; i++) {
      final columnDescr = columns[i];
      final headerCell = headersRow.cells[i];
      if (columnDescr.sortable) {
        headerCell.element.onClick.listen((event) {
          onSortClick(headerCell, i);
        });
      }
    }
    addAll([headersRow, scrollablePanel]);
  }

  set checkboxVisible(bool value) {
    _checkboxVisible = value;
    (headersRow as ObjectTableHeaderRow).checkbox.visible = value;
    for (final row in rows) {
      final objectRow = row as ObjectTableRow<T>;
      objectRow.checkbox.visible = value;
    }
  }

  bool get checkboxVisible => _checkboxVisible;

  @override
  AbstractTableRow createRow(List rowData) {
    throw UnsupportedError('createRow is not supported use createObjectRow instead');
  }

  ObjectTableRow createObjectRow(T object) {
    final newRow = ObjectTableRow(objectRowAdapter, columns)
      ..object = object
      ..checkbox.visible = checkboxVisible;
    newRow.checkbox.onValueChange.listen((event) {
      fireOnCheckBoxSelect(ObjectTableSelectEvent(object, selected: event.newValue));
      var allSelected = true;
      var allUnselected = true;
      for (final row in rows) {
        final objectRow = row as ObjectTableRow<T>;
        if (objectRow.checkbox.value) {
          if (allUnselected) {
            allUnselected = false;
          }
        } else {
          if (allSelected) {
            allSelected = false;
          }
        }
      }
      if (allSelected) {
        (headersRow as ObjectTableHeaderRow).checkbox.value = true;
      } else if (allUnselected) {
        (headersRow as ObjectTableHeaderRow).checkbox.value = false;
      } else {
        (headersRow as ObjectTableHeaderRow).checkbox.isIndeterminate = true;
      }
    });
    formatRow(newRow);
    rows.add(newRow);
    scrollablePanel.add(newRow);
    return newRow;
  }

  set objects(List<T> newObjects) {
    if (newObjects.isEmpty) {
      clear();
    }
    if (newObjects.length <= rows.length) {
      if (newObjects.length < rows.length) {
        rows.removeRange(newObjects.length, rows.length);
      }
      for (var i = 0; i < newObjects.length; i++) {
        (rows[i] as ObjectTableRow<T>).object = newObjects[i];
      }
    } else {
      for (var i = 0; i < rows.length; i++) {
        (rows[i] as ObjectTableRow<T>).object = newObjects[i];
      }
      for (var i = rows.length; i < newObjects.length; i++) {
        createObjectRow(newObjects[i]);
      }
    }
  }

  List<T> get objects => rows.map((e) => (e as ObjectTableRow<T>).object).toList();

  void fireOnCheckBoxSelect(ObjectTableSelectEvent<T> object) {
    _onSelectController.sink.add(object);
  }

  Stream<ObjectTableSelectEvent<T>> get onSelect => _onSelectController.stream;

  void dispose() {
    _onSelectController.close();
  }

  List<T> getSelected() {
    final ret = <T>[];
    for (var i = 0; i < objects.length; i++) {
      final row = rows[i] as ObjectTableRow<T>;
      if (row.checkbox.value) {
        ret.add(row.object);
      }
    }
    return ret;
  }

  @override
  void sortData({int columnIndex = 0, bool desc = false}) {
    final sortRows = <ObjectTableRow<T>>[];
    for (final row in rows) {
      sortRows.add(row as ObjectTableRow<T>);
    }
    if (desc) {
      sortRows.sort((row1, row2) {
        final data1 = row1.cells[columnIndex].value;
        final data2 = row2.cells[columnIndex].value;
        return compareDynamics(data2, data1);
      });
    } else {
      sortRows.sort((row1, row2) {
        final data1 = row1.cells[columnIndex].value;
        final data2 = row2.cells[columnIndex].value;
        return compareDynamics(data1, data2);
      });
    }
    clear();
    sortRows.forEach((row) {
      createObjectRow(row.object);
    });
  }

  void headerCheckboxValueChange(ValueChangeEvent<bool> event) {
    for (final row in rows) {
      if (row is ObjectTableRow<T>) {
        if (row.checkbox.value != event.newValue) {
          row.checkbox.value = event.newValue;
          fireOnCheckBoxSelect(ObjectTableSelectEvent(row.object, selected: event.newValue));
        }
      }
    }
  }
}
