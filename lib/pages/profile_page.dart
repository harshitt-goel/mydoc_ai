import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  File? _profileImage;

  // User data
  String _name = "John Doe";
  String _email = "john.doe@example.com";
  String _phone = "+1 234 567 8900";
  String _bloodType = "O+";
  String _allergies = "None";
  String _medicalConditions = "None";

  Future<void> _pickImage() async {

    setState(() {
      _profileImage = null;
    });
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/placeholder_profile.png')
                      as ImageProvider,
                      child: _profileImage == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    if (_isEditing)
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          child: Icon(Icons.camera_alt, size: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildEditableField(
                    label: 'Full Name',
                    value: _name,
                    icon: Icons.person,
                    isEditing: _isEditing,
                    onSaved: (value) => _name = value!,
                  ),
                  _buildEditableField(
                    label: 'Email',
                    value: _email,
                    icon: Icons.email,
                    isEditing: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onSaved: (value) => _email = value!,
                  ),
                  _buildEditableField(
                    label: 'Phone Number',
                    value: _phone,
                    icon: Icons.phone,
                    isEditing: _isEditing,
                    keyboardType: TextInputType.phone,
                    onSaved: (value) => _phone = value!,
                  ),
                  _buildEditableField(
                    label: 'Blood Type',
                    value: _bloodType,
                    icon: Icons.bloodtype,
                    isEditing: _isEditing,
                    onSaved: (value) => _bloodType = value!,
                  ),
                  _buildEditableField(
                    label: 'Allergies',
                    value: _allergies,
                    icon: Icons.warning,
                    isEditing: _isEditing,
                    maxLines: 2,
                    onSaved: (value) => _allergies = value!,
                  ),
                  _buildEditableField(
                    label: 'Medical Conditions',
                    value: _medicalConditions,
                    icon: Icons.medical_information,
                    isEditing: _isEditing,
                    maxLines: 3,
                    onSaved: (value) => _medicalConditions = value!,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!_isEditing)
              Column(
                children: [
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Consultation History'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to consultation history
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('App Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to settings
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Log Out'),
                    onTap: () {
                      // Implement logout functionality
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String value,
    required IconData icon,
    required bool isEditing,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: isEditing
          ? TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onSaved: onSaved,
      )
          : ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}

