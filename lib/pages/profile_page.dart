import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  Future<void> _pickImage() async {
    // Placeholder for image picker logic
    setState(() {
      _profileImage = null;
    });
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
    }
  }

  Widget _buildCupertinoField({
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
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: CupertinoColors.systemGrey2)),
        const SizedBox(height: 6),
        CupertinoTextFormFieldRow(
          initialValue: initialValue,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          keyboardType: keyboardType,
          maxLines: maxLines,
          placeholder: label,
          decoration: BoxDecoration(
            color: CupertinoColors.darkBackgroundGray,
            borderRadius: BorderRadius.circular(12),
          ),
          style: const TextStyle(color: CupertinoColors.white),
          validator: (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return 'Required';
            }
            return null;
          },
          onSaved: onSaved,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildReadOnlyTile(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.darkBackgroundGray,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.systemGrey)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 16, color: CupertinoColors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: const CupertinoThemeData(brightness: Brightness.dark),
      home: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.black,
        navigationBar: CupertinoNavigationBar(
          middle: const Text("My Profile"),
          trailing: GestureDetector(
            onTap: _isEditing ? _saveProfile : _toggleEdit,
            child: Icon(
              _isEditing
                  ? CupertinoIcons.check_mark
                  : CupertinoIcons.pencil_outline,
            ),
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _isEditing ? _pickImage : null,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: CupertinoColors.systemGrey4,
                              image: _profileImage != null
                                  ? DecorationImage(
                                  image: FileImage(_profileImage!),
                                  fit: BoxFit.cover)
                                  : null,
                            ),
                            child: _profileImage == null
                                ? const Icon(CupertinoIcons.person_solid,
                                size: 56, color: CupertinoColors.white)
                                : null,
                          ),
                          if (_isEditing)
                            const Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: CupertinoColors.systemBlue,
                                child: Icon(CupertinoIcons.camera_fill,
                                    color: CupertinoColors.white, size: 16),
                              ),
                            )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text("Vitals",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_isEditing)
                    Column(
                      children: [
                        _buildCupertinoField(
                          label: "Full Name",
                          initialValue: _name,
                          required: true,
                          onSaved: (val) => _name = val ?? '',
                        ),
                        _buildCupertinoField(
                          label: "Email",
                          initialValue: _email,
                          keyboardType: TextInputType.emailAddress,
                          required: true,
                          onSaved: (val) => _email = val ?? '',
                        ),
                        _buildCupertinoField(
                          label: "Phone",
                          initialValue: _phone,
                          keyboardType: TextInputType.phone,
                          onSaved: (val) => _phone = val ?? '',
                        ),
                        _buildCupertinoField(
                          label: "Blood Type",
                          initialValue: _bloodType,
                          onSaved: (val) => _bloodType = val ?? '',
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

                  const SizedBox(height: 24),
                  const Text("Health Info",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_isEditing)
                    Column(
                      children: [
                        _buildCupertinoField(
                          label: "Allergies",
                          initialValue: _allergies,
                          onSaved: (val) => _allergies = val ?? '',
                          maxLines: 2,
                        ),
                        _buildCupertinoField(
                          label: "Medical Conditions",
                          initialValue: _medicalConditions,
                          onSaved: (val) => _medicalConditions = val ?? '',
                          maxLines: 2,
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildReadOnlyTile("Allergies", _allergies),
                        _buildReadOnlyTile(
                            "Medical Conditions", _medicalConditions),
                      ],
                    ),

                  const SizedBox(height: 30),

                  if (!_isEditing)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Account",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        CupertinoListTile(
                          icon: CupertinoIcons.time,
                          title: "Consultation History",
                          onTap: () {},
                        ),
                        CupertinoListTile(
                          icon: CupertinoIcons.settings,
                          title: "App Settings",
                          onTap: () {},
                        ),
                        CupertinoListTile(
                          icon: CupertinoIcons.square_arrow_right,
                          title: "Log Out",
                          onTap: () {},
                          color: CupertinoColors.systemRed,
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

// ✅ Custom Cupertino Tile
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
    this.color = CupertinoColors.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: CupertinoColors.systemGrey4),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: TextStyle(color: color, fontSize: 16),
              ),
            ),
            const Icon(CupertinoIcons.chevron_forward,
                size: 18, color: CupertinoColors.systemGrey2),
          ],
        ),
      ),
    );
  }
}

// ✅ Custom Success Dialog
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
    _controller =
        AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();

    // Auto-close after 1.2 seconds
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: CupertinoAlertDialog(
        title: Column(
          children: const [
            Icon(CupertinoIcons.checkmark_seal_fill,
                color: CupertinoColors.systemGreen, size: 48),
            SizedBox(height: 8),
            Text("Saved Successfully"),
          ],
        ),
      ),
    );
  }
}
