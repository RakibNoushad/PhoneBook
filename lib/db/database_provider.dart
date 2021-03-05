import 'dart:async';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = 'contactTable';
final String idColumn = 'idColumn';
final String nameColumn = 'nameColumn';
final String emailColumn = 'emailColumn';
final String phoneColumn = 'phoneColumn';
final String imgColumn = 'imgColumn';

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;
  ContactHelper.internal();
  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'contactsnew.db');
    return await openDatabase(path, version: 1,
        onCreate: (db, newerVersion) async {
          await db.execute('CREATE TABLE $contactTable('
              '$idColumn INTEGER PRIMARY KEY,'
              '$nameColumn TEXT,'
              '$emailColumn TEXT,'
              '$phoneColumn TEXT,'
              '$imgColumn TEXT)');
        });
  }

  Future<Contact> saveContact(Contact contact) async {
    var dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    var dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: '$idColumn = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    var dbContact = await db;
    return await dbContact
        .delete(contactTable, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    var dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(),
        where: '$idColumn = ?', whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    var dbContact = await db;
    List listMap = await dbContact.rawQuery('SELECT * FROM $contactTable');
    var listContact = <Contact>[];
    for (Map m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumber() async {
    var dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact.rawQuery('SELECT COUNT(*) FROM $contactTable'));
  }

  Future close() async {
    var dbContact = await db;
    dbContact.close();
  }
}

class Item {
  Item({this.label, this.value});

  String label, value;

  Item.fromMap(Map m) {
    label = m["label"];
    value = m["value"];
  }
}

class Contact {
  int id;
  String identifier;
  String displayName;
  String givenName;
  String middleName;
  String prefix;
  String suffix;
  String familyName;
  String company;
  String jobTitle;
  Iterable<Item> emails = [];
  Iterable<Item> phones = [];
  Uint8List avatar;

  Contact();

  Contact.fromMap(Map m) {
    id = m[idColumn];
    identifier = m["identifier"];
    displayName = m["displayName"];
    givenName = m["givenName"];
    middleName = m["middleName"];
    familyName = m["familyName"];
    prefix = m["prefix"];
    suffix = m["suffix"];
    company = m["company"];
    jobTitle = m["jobTitle"];
    emails = (m["emails"] as Iterable)?.map((m) => Item.fromMap(m));
    phones = (m["phones"] as Iterable)?.map((m) => Item.fromMap(m));
    avatar = m["avatar"];
  }

  Map toMap() {
    var map = <String, dynamic>{
      nameColumn: displayName,
      emailColumn: emails,
      phoneColumn: phones,
      imgColumn: avatar
    };
    return map;
  }

  @override
  String toString() {
    return 'Contact('
        'id: $id,'
        'name: $displayName, '
        'email: $emails, '
        'phone: $phones, '
        'img: $avatar)';
  }
}