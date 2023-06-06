import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender;
  final TextEditingController _addressController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future getImage() async {
    await requestStoragePermission();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> uploadImageToFirebase() async {
    if (_image != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userId = currentUser?.uid;
      if (userId != null) {
        final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('$userId.jpg');

        await firebaseStorageRef.putFile(_image!);
        final downloadURL = await firebaseStorageRef.getDownloadURL();

        // Save the downloadURL to the user's profile document in Firestore
        FirebaseFirestore.instance
            .collection('userdetails')
            .doc(userId)
            .set({'profileImage': downloadURL}, SetOptions(merge: true));
      }
    }
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
        }, SetOptions(merge: true));
      }
    }
  }

  @override
  void initState() {
    super.initState();

    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;
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
                GestureDetector(
                  onTap: getImage,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: _image != null
                        ? Image.file(_image!).image
                        : NetworkImage(
                            '${FirebaseAuth.instance.currentUser?.email.hashCode}?d=robohash',
                          ),
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
                  items: [
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
