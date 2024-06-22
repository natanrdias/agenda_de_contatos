import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key, required this.contact, required this.list});

  final Contact? contact;
  final List<Contact> list;

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
      _emailController.text = widget.contact!.email;
      _phoneController.text = widget.contact!.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_nameController.text == ''
              ? 'Novo Contato'
              : _nameController.text),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {});
            if (_nameController.text != null &&
                _nameController.text.isNotEmpty) {
              dynamic _contact;
              if(widget.contact == null){
                _contact = NewContact(
                  name: _nameController.text,
                  email: _emailController.text,
                  phone: _phoneController.text,
                  img: _imgController.text,
                );
                ContactHelper().saveContact(_contact);
              }else{
                final _contact = Contact(
                  id: widget.contact!.id,
                  name: _nameController.text,
                  email: _emailController.text,
                  phone: _phoneController.text,
                  img: _imgController.text,
                );
                ContactHelper().updateContact(_contact);
              }

              Navigator.pop(context, _contact);
            } else {
              FocusScope.of(context).requestFocus(FocusNode());
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Nome do Contato'),
                    content: const Text('Preencha o nome do contato!'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Ok'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.save),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140.0,
                  height: 140.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: widget.contact?.img != null
                          ? FileImage(File(widget.contact!.img))
                          : const AssetImage('lib/images/person.png')
                              as ImageProvider,
                    ),
                  ),
                ),
                onTap: (){
                  ImagePicker().pickImage(source: ImageSource.gallery).then((file) {
                    if(file == null) return;
                    setState(() {
                      _imgController.text = file.path;
                    });
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Nome'),
                controller: _nameController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                controller: _phoneController,

              ),
            ],
          ),
        ));
  }
}
