import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  File? _profileImage;

  String _name = "John Doe";
  String _email = "john.doe@example.com";
  String _phone = "+1 234 567 8900";
  String _bloodType = "O+";
  String _allergies = "None";
  String _medicalConditions = "None";

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text("Error"),
            content: Text("Failed to pick image: $e"),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  void _saveProfile() {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      setState(() => _isEditing = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCupertinoDialog(
          context: context,
          builder: (_) => const SuccessDialog(),
        );
      });
    } else {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("Invalid Input"),
          content: const Text("Please fill all required fields correctly."),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildCupertinoField({
    required String label,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFFA3BFFA),
          ),
        ),
        const SizedBox(height: 8),
        CupertinoTextFormFieldRow(
          initialValue: initialValue,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          keyboardType: keyboardType,
          maxLines: maxLines,
          placeholder: "Enter $label",
          placeholderStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2A3B4A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF3B4A5A),
              width: 0.5,
            ),
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          cursorColor: const Color(0xFF4A90E2),
          validator: validator ??
              (required
                  ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Required';
                }
                return null;
              }
                  : null),
          onSaved: onSaved,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildReadOnlyTile(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A3B4A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF3B4A5A),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFFA3BFFA),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF4A90E2),
        scaffoldBackgroundColor: Color(0xFF1A252F),
      ),
      home: CupertinoPageScaffold(
        backgroundColor: const Color(0xFF1A252F),
        navigationBar: CupertinoNavigationBar(
          middle: const Text(
            "My Profile",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          trailing: GestureDetector(
            onTap: _isEditing ? _saveProfile : _toggleEdit,
            child: Icon(
              _isEditing
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.pencil_circle,
              size: 28,
              color: const Color(0xFF4A90E2),
            ),
          ),
          backgroundColor: const Color(0xFF1A252F).withOpacity(0.8),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _isEditing ? _pickImage : null,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2A3B4A),
                              border: Border.all(
                                color: const Color(0xFF3B4A5A),
                                width: 2,
                              ),
                              image: _profileImage != null
                                  ? DecorationImage(
                                image: FileImage(_profileImage!),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: _profileImage == null
                                ? const Icon(
                              CupertinoIcons.person_crop_circle_fill,
                              size: 80,
                              color: Color(0xFFA3BFFA),
                            )
                                : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFF4A90E2),
                                child: Icon(
                                  CupertinoIcons.camera_fill,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    "Personal Information",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isEditing)
                    Column(
                      children: [
                        _buildCupertinoField(
                          label: "Full Name",
                          initialValue: _name,
                          required: true,
                          onSaved: (val) => _name = val ?? '',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            if (value.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        _buildCupertinoField(
                          label: "Email",
                          initialValue: _email,
                          keyboardType: TextInputType.emailAddress,
                          required: true,
                          onSaved: (val) => _email = val ?? '',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        _buildCupertinoField(
                          label: "Phone",
                          initialValue: _phone,
                          keyboardType: TextInputType.phone,
                          onSaved: (val) => _phone = val ?? '',
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value)) {
                                return 'Enter a valid phone number';
                              }
                            }
                            return null;
                          },
                        ),
                        _buildCupertinoField(
                          label: "Blood Type",
                          initialValue: _bloodType,
                          onSaved: (val) => _bloodType = val ?? '',
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                                  .contains(value.toUpperCase())) {
                                return 'Enter a valid blood type (e.g., A+, O-)';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildReadOnlyTile("Full Name", _name),
                        _buildReadOnlyTile("Email", _email),
                        _buildReadOnlyTile("Phone", _phone),
                        _buildReadOnlyTile("Blood Type", _bloodType),
                      ],
                    ),

                  const SizedBox(height: 32),
                  const Text(
                    "Health Information",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isEditing)
                    Column(
                      children: [
                        _buildCupertinoField(
                          label: "Allergies",
                          initialValue: _allergies,
                          onSaved: (val) => _allergies = val ?? '',
                          maxLines: 3,
                        ),
                        _buildCupertinoField(
                          label: "Medical Conditions",
                          initialValue: _medicalConditions,
                          onSaved: (val) => _medicalConditions = val ?? '',
                          maxLines: 3,
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildReadOnlyTile("Allergies", _allergies),
                        _buildReadOnlyTile("Medical Conditions", _medicalConditions),
                      ],
                    ),

                  const SizedBox(height: 32),

                  if (!_isEditing)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Account",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoListTile(
                          icon: CupertinoIcons.time,
                          title: "Consultation History",
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const ConsultationHistoryPage(),
                              ),
                            );
                          },
                        ),
                        CupertinoListTile(
                          icon: CupertinoIcons.settings,
                          title: "App Settings",
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                        CupertinoListTile(
                          icon: CupertinoIcons.square_arrow_right,
                          title: "Log Out",
                          onTap: () {
                            showCupertinoDialog(
                              context: context,
                              builder: (_) => CupertinoAlertDialog(
                                title: const Text("Log Out"),
                                content: const Text("Are you sure you want to log out?"),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text("Cancel"),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                  CupertinoDialogAction(
                                    isDestructiveAction: true,
                                    child: const Text("Log Out"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      // Implement logout logic here
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          color: const Color(0xFFE57373),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CupertinoListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  const CupertinoListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = const Color(0xFFA3BFFA),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A3B4A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF3B4A5A),
            width: 0.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_forward,
              size: 20,
              color: Color(0xFFA3BFFA),
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessDialog extends StatefulWidget {
  const SuccessDialog({super.key});

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.checkmark_seal_fill,
              color: Color(0xFF4A90E2),
              size: 50,
            ),
            const SizedBox(height: 12),
            const Text(
              "Profile Updated",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your information has been saved successfully.",
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFFA3BFFA),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder pages for navigation
class ConsultationHistoryPage extends StatelessWidget {
  const ConsultationHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Consultation History"),
        backgroundColor: Color(0xFF1A252F),
      ),
      child: Center(
        child: Text(
          "Consultation History Page",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF1A252F),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("App Settings"),
        backgroundColor: Color(0xFF1A252F),
      ),
      child: Center(
        child: Text(
          "App Settings Page",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: const Color(0xFF1A252F),
    );
  }
}