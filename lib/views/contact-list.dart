import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:phone_book/theme/routes.dart';

import 'package:phone_book/views/contact-details.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactList extends StatefulWidget {
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  List<Contact> contacts = [];
  List<Contact> contactsFiltered = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPermissions();
  }

  flattenPhoneNumber(String phnStr) {
    return phnStr.replaceAll(RegExp(r'^(\+)|\D'), '');
  }

  getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      getAllContacts();
      searchController.addListener(() {
        filterContacts();
      });
    }
  }

  getAllContacts() async {
    List<Contact> _contacts = (await ContactsService.getContacts()).toList();
    setState(() {
      contacts = _contacts.toList();
    });
  }

  filterContacts() {
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if (searchController.text.isNotEmpty) {
      _contacts.retainWhere((contact) {
        String searchTerm = searchController.text.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.displayName.toLowerCase();

        bool nameMatches = contactName.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.phones.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value);
          return phnFlattened.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });

      setState(() {
        contactsFiltered = _contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSearching = searchController.text.isNotEmpty;

    List<String> actions = <String>['Sort a-z', 'Sort z-a', 'Sort 1-9', 'Sort 9-1', 'Logout'];

    onAction(String action) async {
      switch (action) {
        case 'Sort a-z':
          contacts.sort((a, b) {
           return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
          });
          break;
        case 'Sort z-a':
          contacts.sort((a, b) {
            return b.displayName.toLowerCase().compareTo(a.displayName.toLowerCase());
          });
          break;
        case 'Sort 1-9':
          contacts.sort((a, b) {
            return a.phones.elementAt(0).value.toString().compareTo(b.phones.elementAt(0).value.toString());
          });
          break;
        case 'Sort 9-1':
          contacts.sort((a, b) {
            return b.phones.elementAt(0).value.toString().compareTo(a.phones.elementAt(0).value.toString());
          });
          break;
        case 'Logout':
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.authLogin, (route) => false);
          break;
      }
      setState(() {});
      print(action);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Contact List"),
        actions: [            Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton(
              onSelected: onAction,
              itemBuilder: (BuildContext context) {
                return actions.map((String action) {
                  return PopupMenuItem(
                    child: Text(action),
                    value: action,
                  );
                }).toList();
              },
            ),
          ),
        ),],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        onPressed: () async {
          try {
            Contact contact = await ContactsService.openContactForm();
            if (contact != null) {
              getAllContacts();
            }
          } on FormOperationException catch (e) {
            switch (e.errorCode) {
              case FormOperationErrorCode.FORM_OPERATION_CANCELED:
              case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
              case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
                print(e.toString());
            }
          }
        },
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Container(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(
                          borderSide: new BorderSide(
                              color: Theme
                                  .of(context)
                                  .primaryColor)),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme
                            .of(context)
                            .primaryColor,
                      )),
                )),
            Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: isSearching == true
                      ? contactsFiltered.length
                      : contacts.length,
                  itemBuilder: (context, index) {
                    Contact contact = isSearching == true
                        ? contactsFiltered[index]
                        : contacts[index];
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ContactDetails(
                                  contact,
                                  onContactDelete: (Contact _contact){
                                    getAllContacts();
                                    Navigator.of(context).pop();
                                  },
                                  onContactUpdate: (Contact _contact){
                                    getAllContacts();
                                  },
                                )));
                      },
                      title: Text(contact.displayName),
                      subtitle: Text(contact.phones
                          .elementAt(0)
                          .value),
                      leading: (contact.avatar != null &&
                          contact.avatar.length > 0)
                          ? CircleAvatar(
                        backgroundImage: MemoryImage(contact.avatar),
                      )
                          : CircleAvatar(
                        child: Text(
                          contact.initials(),
                        ),
                      ),
                    );
                  },
                ))
          ],
        ),
      ),
    );
  }
}
