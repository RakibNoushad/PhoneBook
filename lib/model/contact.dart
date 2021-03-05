// import 'dart:typed_data';
//
// class Item {
//   Item({this.label, this.value});
//
//   String label, value;
//
//   Item.fromMap(Map m) {
//     label = m["label"];
//     value = m["value"];
//   }
// }
//
// class Contact {
//   String identifier;
//   String displayName;
//   String givenName;
//   String middleName;
//   String prefix;
//   String suffix;
//   String familyName;
//   String company;
//   String jobTitle;
//   Iterable<Item> emails = [];
//   Iterable<Item> phones = [];
//   Uint8List avatar;
//
//   Contact();
//
//   Contact.fromMap(Map m) {
//     identifier = m["identifier"];
//     displayName = m["displayName"];
//     givenName = m["givenName"];
//     middleName = m["middleName"];
//     familyName = m["familyName"];
//     prefix = m["prefix"];
//     suffix = m["suffix"];
//     company = m["company"];
//     jobTitle = m["jobTitle"];
//     emails = (m["emails"] as Iterable)?.map((m) => Item.fromMap(m));
//     phones = (m["phones"] as Iterable)?.map((m) => Item.fromMap(m));
//     avatar = m["avatar"];
//   }
//
//   Map toMap() {
//     var map = <String, dynamic>{
//       identifier: identifier,
//       displayName: displayName,
//       givenName: givenName,
//       middleName: middleName,
//       familyName: familyName,
//       prefix: prefix,
//       suffix: suffix,
//       company: company,
//       jobTitle: jobTitle,
//     };
//     return map;
//   }
//
// }

