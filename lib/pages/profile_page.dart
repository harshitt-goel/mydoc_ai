import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_doctor/models/profile_data.dart';
import 'package:ai_doctor/models/profile_manager.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  File? _profileImage;

  // Profile fields
  String _name = "John Doe";
  String _email = "john.doe@example.com";
  String _phone = "+1 234 567 8900";
  String _bloodType = "O+";
  String _allergies = "None";
  String _medicalConditions = "None";
  int _age = 25;
  String _gender = "Male";
  String _activityLevel = "Moderate";
  double _height = 170.0;
  double _weight = 65.0;

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _loadProfileFromPrefs();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 800);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _loadProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('profile');
    if (data != null) {
      final decoded = jsonDecode(data);
      setState(() {
        _name = decoded['name'] ?? _name;
        _email = decoded['email'] ?? _email;
        _phone = decoded['phone'] ?? _phone;
        _bloodType = decoded['bloodType'] ?? _bloodType;
        _allergies = decoded['allergies'] ?? _allergies;
        _medicalConditions = decoded['medicalConditions'] ?? _medicalConditions;
        _age = decoded['age'] ?? _age;
        _gender = decoded['gender'] ?? _gender;
        _activityLevel = decoded['activityLevel'] ?? _activityLevel;
        _height = (decoded['height'] ?? _height).toDouble();
        _weight = (decoded['weight'] ?? _weight).toDouble();
      });
    }
  }

  Future<void> _saveProfileToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'name': _name,
      'email': _email,
      'phone': _phone,
      'bloodType': _bloodType,
      'allergies': _allergies,
      'medicalConditions': _medicalConditions,
      'age': _age,
      'gender': _gender,
      'activityLevel': _activityLevel,
      'height': _height,
      'weight': _weight,
    };
    await prefs.setString('profile', jsonEncode(data));
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  void _saveProfile() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      _saveProfileToPrefs();
      ProfileManager.setProfile(ProfileData(
        age: _age,
        gender: _gender,
        activityLevel: _activityLevel,
        medicalConditions: _medicalConditions.split(',').map((e) => e.trim()).toList(),
        heightCm: _height,
        weightKg: _weight,
      ));
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    }
  }

  Widget _buildField({
    required String label,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 6),
          child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8))),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF1E3A5F).withOpacity(0.7), const Color(0xFF1E3A5F).withOpacity(0.5)],
            ),
          ),
          child: TextFormField(
            initialValue: initialValue,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            cursorColor: const Color(0xFF4A90E2),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              hintText: "Enter $label",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16),
            ),
            validator: required
                ? (value) => value == null || value.trim().isEmpty ? 'Required' : null
                : null,
            onSaved: onSaved,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReadOnlyTile(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1E3A5F).withOpacity(0.7), const Color(0xFF1E3A5F).withOpacity(0.5)],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('$label:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: Colors.white.withOpacity(0.8)))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontSize: 15, color: Colors.white), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A1E3A),
        cardColor: const Color(0xFF1A3152),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1E3A),
        appBar: AppBar(
          title: const Text("My Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.check_circle : Icons.edit, color: const Color(0xFF4A90E2)),
              onPressed: _isEditing ? _saveProfile : _toggleEdit,
            ),
          ],
        ),
        body: ScaleTransition(
          scale: _scaleAnim,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _isEditing ? _pickImage : null,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFF1E3A5F),
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null ? Icon(Icons.person, size: 60, color: Colors.white.withOpacity(0.7)) : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _sectionHeader(Icons.person_outline, "Personal Information"),
                    const SizedBox(height: 16),
                    if (_isEditing) ...[
                      _buildField(label: "Full Name", initialValue: _name, onSaved: (val) => _name = val ?? '', required: true),
                      _buildField(label: "Email", initialValue: _email, onSaved: (val) => _email = val ?? '', keyboardType: TextInputType.emailAddress, required: true),
                      _buildField(label: "Phone", initialValue: _phone, onSaved: (val) => _phone = val ?? '', keyboardType: TextInputType.phone),
                      _buildField(label: "Blood Type", initialValue: _bloodType, onSaved: (val) => _bloodType = val ?? ''),
                      _buildField(label: "Age", initialValue: '$_age', onSaved: (val) => _age = int.tryParse(val ?? '') ?? _age, keyboardType: TextInputType.number),
                      _buildField(label: "Gender", initialValue: _gender, onSaved: (val) => _gender = val ?? ''),
                      _buildField(label: "Activity Level", initialValue: _activityLevel, onSaved: (val) => _activityLevel = val ?? ''),
                      _buildField(label: "Height (cm)", initialValue: '$_height', onSaved: (val) => _height = double.tryParse(val ?? '') ?? _height, keyboardType: TextInputType.number),
                      _buildField(label: "Weight (kg)", initialValue: '$_weight', onSaved: (val) => _weight = double.tryParse(val ?? '') ?? _weight, keyboardType: TextInputType.number),
                    ] else ...[
                      _buildReadOnlyTile("Full Name", _name),
                      _buildReadOnlyTile("Email", _email),
                      _buildReadOnlyTile("Phone", _phone),
                      _buildReadOnlyTile("Blood Type", _bloodType),
                      _buildReadOnlyTile("Age", '$_age'),
                      _buildReadOnlyTile("Gender", _gender),
                      _buildReadOnlyTile("Activity Level", _activityLevel),
                      _buildReadOnlyTile("Height", '$_height cm'),
                      _buildReadOnlyTile("Weight", '$_weight kg'),
                    ],
                    const SizedBox(height: 32),
                    _sectionHeader(Icons.health_and_safety_outlined, "Health Information"),
                    const SizedBox(height: 16),
                    if (_isEditing) ...[
                      _buildField(label: "Allergies", initialValue: _allergies, onSaved: (val) => _allergies = val ?? ''),
                      _buildField(label: "Medical Conditions", initialValue: _medicalConditions, onSaved: (val) => _medicalConditions = val ?? ''),
                    ] else ...[
                      _buildReadOnlyTile("Allergies", _allergies),
                      _buildReadOnlyTile("Medical Conditions", _medicalConditions),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4A90E2), size: 24),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }
}