import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/contact_helper.dart';
import 'contact_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = [];
  int? removedIndex;
  Contact? removedContact;

  @override
  void initState() {
    super.initState();
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ContactPage(contact: null, list: contacts)))
              .then((value) {
            helper.getAllContacts().then((list) {
              setState(() {
                contacts = list;
              });
            });
          });
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
      body: Container(
        child: ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          },
        ),
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        background: Container(
          color: Colors.red,
          child: const Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          helper.deleteContact(contacts[index].id!);
          setState(() {
            removedContact = contacts[index];
            removedIndex = index;
            contacts.removeAt(index);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text("Contato removido!"),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: "Desfazer",
                  onPressed: () {
                    setState(() {
                      contacts.insert(removedIndex!, removedContact!);
                      helper.saveContact(contacts[removedIndex!]);
                    });
                  },
                )));
          });
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: contacts[index].img != ""
                            ? FileImage(File(contacts[index].img))
                            : const AssetImage("lib/images/person.png")
                                as ImageProvider,
                        fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        contacts[index].name ?? "",
                        style: const TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        contacts[index].email ?? "",
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      Text(
                        contacts[index].phone ?? "",
                        style: const TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextButton(
                        onPressed: () async {
                          _makePhoneCall(contacts[index].phone);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Ligar',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactPage(contact: contacts[index]);
                        },
                        child: const Text(
                          'Editar',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextButton(
                        onPressed: () {
                          helper.deleteContact(contacts[index].id!);
                          setState(() {
                            contacts.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                        child: const Text(
                          'Excluir',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: Colors.red, fontSize: 20.0),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void _showContactPage({Contact? contact}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ContactPage(contact: contact, list: contacts))).then((value) {
      helper.getAllContacts().then((list) {
        setState(() {
          contacts = list;
        });
      });
    });
  }
}
