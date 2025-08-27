// import 'package:reflectable/reflectable.dart';

// class TableReflector extends Reflectable {
//   const TableReflector()
//       : super(
//           typeCapability,
//           declarationsCapability,
//           metadataCapability,
//         );
// }

// const tableReflector = TableReflector();

// String generateCreateTableQuery(Type type) {
//   final classMirror = tableReflector.reflectType(type) as ClassMirror;

//   final tableName = classMirror.simpleName;

//   final buffer = StringBuffer('CREATE TABLE $tableName (');

//   classMirror.declarations.forEach((name, declaration) {
//     if (declaration is VariableMirror) {
//       final fieldName = name;
//       final fieldType = declaration.reflectedType;

//       String sqlType = 'TEXT';
//       if (fieldType == int) {
//         sqlType = 'INTEGER';
//       } else if (fieldType == double) {
//         sqlType = 'REAL';
//       } else if (fieldType == bool) {
//         sqlType = 'INTEGER'; // store as 0/1
//       }

//       buffer.write('$fieldName $sqlType, ');
//     }
//   });

//   // Remove the last comma and space
//   buffer.write('PRIMARY KEY(id));');
//   final query = buffer.toString().replaceAll(', PRIMARY KEY', ' PRIMARY KEY');
//   return query;
// }