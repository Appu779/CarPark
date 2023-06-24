import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/map_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;
  late SharedPreferences _prefs;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _rcController = TextEditingController();
  final TextEditingController _regnumController = TextEditingController();
  Future<void> _loadSelectedGender() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedGender = _prefs.getString('selectedGender');
    });
  }

  Future<void> _saveSelectedGender(String gender) async {
    setState(() {
      _selectedGender = gender;
    });
    await _prefs.setString('selectedGender', gender);
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;
      if (userId != null) {
        FirebaseFirestore.instance.collection('userdetails').doc(userId).set({
          'name': _nameController.text,
          'dob': _dobController.text,
          'gender': _selectedGender,
          'address': _addressController.text,
          'rc': _rcController.text,
          'carno' : _regnumController.text,
        }, SetOptions(merge: true)).then((_) async {
          final prefs = await SharedPreferences.getInstance();
          prefs.setBool('profileCompleted', true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MapScreen(),
            ),
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedGender();

    user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    if (userId != null) {
      FirebaseFirestore.instance
          .collection('userdetails')
          .doc(userId)
          .get()
          .then((docSnapshot) {
        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          _nameController.text = data['name'] ?? '';
          _dobController.text = data['dob'] ?? '';
          _selectedGender = data['gender'];
          _addressController.text = data['address'] ?? '';
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();

    super.dispose();
  }

  String getEmailHash(String email) {
    final emailBytes = utf8.encode(email.toLowerCase().trim());
    final hash = md5.convert(emailBytes);
    return hash.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(
                    user?.photoURL ?? 'https://example.com/default-image.jpg',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                  ),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      _dobController.text =
                          pickedDate.toLocal().toString().split(' ')[0];
                    }
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please select your date of birth';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Male',
                      child: Text('Male'),
                    ),
                    DropdownMenuItem(
                      value: 'Female',
                      child: Text('Female'),
                    ),
                    DropdownMenuItem(
                      value: 'Others',
                      child: Text('Others'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your gender';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitForm,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
