import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_service.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> with AutomaticKeepAliveClientMixin {
  final TextEditingController _symptomController = TextEditingController();
  final List<String> _symptomChips = [
    'Headache',
    'Fever',
    'Cough',
    'Fatigue',
    'Stomach Pain',
    'Sore Throat',
    'Nausea',
    'Cold',
  ];
  final Set<String> _selectedSymptoms = {};
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _loading = false;
  String _result = '';

  @override
  bool get wantKeepAlive => true; // This preserves the state

  Future<void> _send() async {
    setState(() => _loading = true);
    try {
      _result = await AIService.analyzeSymptoms(
        symptoms: _selectedSymptoms.toList(),
        customPrompt: _symptomController.text.trim(),
      );
    } catch (e) {
      _result = "Error: ${e.toString()}";
    }
    setState(() => _loading = false);
  }

  void _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      backgroundColor: const Color(0xFF1B1B1B),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Gallery', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final file = await _picker.pickImage(source: ImageSource.gallery);
                if (file != null) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SmartImageConsult(image: File(file.path)),
                      maintainState: true, // Preserve state when navigating
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () async {
                final file = await _picker.pickImage(source: ImageSource.camera);
                if (file != null) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SmartImageConsult(image: File(file.path)),
                      maintainState: true, // Preserve state when navigating
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: const Color(0xFF001121),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'AI Doctor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 26,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tell me what you're feeling today.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _symptomController,
                      cursorColor: Colors.white,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Describe your symptoms...',
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF223D5D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _symptomChips.map((chip) {
                        final bool selected = _selectedSymptoms.contains(chip);
                        return ChoiceChip(
                          label: Text(chip),
                          selected: selected,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.white,
                          ),
                          backgroundColor: const Color(0xFF223D5C),
                          selectedColor: Colors.blue,
                          onSelected: (_) {
                            setState(() {
                              selected
                                  ? _selectedSymptoms.remove(chip)
                                  : _selectedSymptoms.add(chip);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                    _GlassCard(
                      title: "Smart Image Consult",
                      description: "Diagnose using a photo or scan.",
                      icon: Icons.camera_alt_rounded,
                      onTap: _pickImage,
                    ),
                    const SizedBox(height: 16),
                    if (_result.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00223F),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Text(
                          _result,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _loading ? null : _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF223D5C).withOpacity(0.8),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* --------------------------------------------------- */

class SmartImageConsult extends StatefulWidget {
  final File image;
  const SmartImageConsult({required this.image, Key? key}) : super(key: key);

  @override
  State<SmartImageConsult> createState() => _SmartImageConsultState();
}

class _SmartImageConsultState extends State<SmartImageConsult> {
  String diagnosis = '';
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processImage();
    });
  }

  Future<void> _processImage() async {
    try {
      setState(() {
        loading = true;
        error = '';
      });

      // Verify image exists
      final exists = await widget.image.exists();
      if (!exists) {
        throw Exception('Selected image no longer exists');
      }

      // Get image size
      final size = await widget.image.length();
      if (size > 5 * 1024 * 1024) { // 5MB limit
        throw Exception('Image is too large (${size ~/ (1024 * 1024)}MB)');
      }

      // Read image bytes
      final bytes = await widget.image.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Failed to read image data');
      }

      // Call AI service
      final res = await AIService.analyzeImage(bytes);

      setState(() {
        diagnosis = res;
        loading = false;
      });

    } catch (e) {
      setState(() {
        error = 'Failed to analyze image: ${e.toString()}';
        diagnosis = '';
        loading = false;
      });
      debugPrint('Image Analysis Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Smart Image Consult",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Image Preview
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.file(widget.image,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stack) {
                    return Center(
                      child: Text('Failed to load image',
                          style: TextStyle(color: Colors.white)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Error Message
              if (error.isNotEmpty)
                Text(error, style: TextStyle(color: Colors.red)),

              // Loading or Results
              if (loading)
                const Center(child: CircularProgressIndicator(color: Colors.white))
              else if (diagnosis.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: _AnimatedTextReveal(text: diagnosis),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/* Word-level fade-in reveal */
class _AnimatedTextReveal extends StatefulWidget {
  final String text;
  const _AnimatedTextReveal({required this.text});

  @override
  State<_AnimatedTextReveal> createState() => __AnimatedTextRevealState();
}

class __AnimatedTextRevealState extends State<_AnimatedTextReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<String> _words;
  @override
  void initState() {
    super.initState();
    _words = widget.text.split(' ');
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_words.length * 40)),
    )..forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final revealCount =
        (_controller.value * _words.length).clamp(0, _words.length).floor();
        return Text(
          _words.take(revealCount).join(' '),
          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/* --------------------------------------------------- */

class _GlassCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _GlassCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF002B5B).withOpacity(0.75),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.blue.withOpacity(0.07), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
