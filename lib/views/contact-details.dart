import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:phone_book/views/contact-avatar.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDetails extends StatefulWidget {
  ContactDetails(this.contact, {this.onContactUpdate, this.onContactDelete});

  Contact contact;
  final Function(Contact) onContactUpdate;
  final Function(Contact) onContactDelete;

  @override
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {
  @override
  Widget build(BuildContext context) {
    List<String> actions = <String>['Edit', 'Delete'];

    showDelConfirmation() {
      Widget cancelButton = FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text('Cancel'),
      );

      Widget deleteButton = FlatButton(
        onPressed: () async {
          await ContactsService.deleteContact(widget.contact);
          widget.onContactDelete(widget.contact);
          Navigator.of(context).pop();
        },
        child: Text('Delete'),
        color: Colors.red,
      );

      AlertDialog alert = AlertDialog(
        title: Text('Delete Contact?'),
        content: Text('Are you sure you want to delete this contact?'),
        actions: <Widget>[
          cancelButton,
          deleteButton,
        ],
      );

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          });
    }

    onAction(String action) async {
      switch (action) {
        case 'Edit':
          try {
            Contact updatedContact =
            await ContactsService.openExistingContact(widget.contact);
            setState(() {
              widget.contact = updatedContact;
              widget.onContactUpdate(widget.contact);
            });
          } on FormOperationException catch (e) {
            switch (e.errorCode) {
              case FormOperationErrorCode.FORM_OPERATION_CANCELED:
              case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
              case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
                print(e.toString());
            }
          }
          break;
        case 'Delete':
          showDelConfirmation();
          break;
      }
    }

    return Scaffold(
      body: SafeArea(
          child: Column(
            children: <Widget>[
            Container(
            height: 180,
            decoration: BoxDecoration(color: Colors.grey[300]),
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Center(child: ContactAvatar(widget.contact, 100)),
                Align(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  alignment: Alignment.topLeft,
                ),
                Align(
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
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.all(20),
                children: <Widget>[
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: <Widget>[
            //     callOption,
            //     messageOption,
            //   ],
            // ),
            ListTile(
            title: Text("Name"),
            trailing: Text(widget.contact.givenName ?? ""),
          ),
          ListTile(
            title: Text("Family name"),
            trailing: Text(widget.contact.familyName ?? ""),
          ),
          Column(
              children: <Widget>[
          ListTile(title: Text("Phones")),
      Column(
        children: widget.contact.phones
            .map(
              (i) =>
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0),
                // child: ListTile(
                //   title: Text(i.label ?? ""),
                //   subtitle: Text(i.value ?? ""),
                child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                Text(i.label.toUpperCase() ?? ""),
                Text(i.value ?? ""),
                Material(
                  elevation: 2.0,
                  borderRadius:
                  BorderRadius.circular(18.0),
                  color: Colors.blue,
                  child: IconButton(
                    icon: Icon(
                      Icons.call_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      final phone = i.value;
                      launch('tel:${phone.toString()}');
                      Navigator.pop(context);
                    },
                  ),
                ),
                Material(
                  elevation: 2.0,
                  borderRadius: BorderRadius.circular(15.0),
                  color: Colors.green,
                  child: IconButton(
                    icon: Icon(
                      Icons.message_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      final phone = i.value;
                      launch('sms:${phone.toString()}');
                      Navigator.pop(context);
                    },
                  ),
                ),
                ],
              ),
        ),
        // ),
      )
          .toList(),
    )],
    )
    ]),
    )
    ],
    ),
    )
    ,
    );
  }
}
