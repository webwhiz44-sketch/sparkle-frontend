import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/api_client.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late List<String> _selectedInterests;
  File? _newAvatar;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  final List<String> _allInterests = [
    'Fashion', 'Wellness', 'Career', 'Relationships',
    'Travel', 'Food', 'Art', 'Fitness',
    'Books', 'Mental Health', 'Dating', 'Parenting',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _selectedInterests = List<String>.from(widget.user.interests);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
    if (image != null) setState(() => _newAvatar = File(image.path));
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name cannot be empty'),
            backgroundColor: Color(0xFFE53935)),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      String? avatarUrl = widget.user.profileImageUrl;
      if (_newAvatar != null) {
        avatarUrl = await ApiClient.uploadImage('/api/uploads/image', _newAvatar!.path)
            .then((res) => ApiClient.parseResponse(res) as String);
      }
      await UserService.updateProfile(
        displayName: name,
        bio: _bioController.text.trim(),
        interests: _selectedInterests,
        profileImageUrl: avatarUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated ✨'),
            backgroundColor: Color(0xFFBE1373)),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFE53935)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save. Try again.'),
            backgroundColor: Color(0xFFE53935)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Profile',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1A1A1A))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSaving
                ? const Center(
                    child: SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(
                            color: Color(0xFFBE1373), strokeWidth: 2)))
                : GestureDetector(
                    onTap: _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFBE1373), Color(0xFFEC407A)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Save',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13)),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildAvatarPicker(),
            const SizedBox(height: 24),
            _buildSection(
              label: 'DISPLAY NAME',
              child: TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A1A)),
                decoration: _inputDecoration('Your display name'),
              ),
            ),
            const SizedBox(height: 12),
            _buildSection(
              label: 'BIO',
              child: TextField(
                controller: _bioController,
                maxLines: 4,
                maxLength: 200,
                style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                decoration: _inputDecoration('Tell us about yourself...'),
              ),
            ),
            const SizedBox(height: 12),
            _buildInterestsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    final hasAvatar = _newAvatar != null || widget.user.profileImageUrl != null;
    return Center(
      child: GestureDetector(
        onTap: _pickAvatar,
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [Color(0xFFEC407A), Color(0xFF880E4F)]),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFFBE1373).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: ClipOval(
                child: _newAvatar != null
                    ? Image.file(_newAvatar!, fit: BoxFit.cover)
                    : widget.user.profileImageUrl != null
                        ? Image.network(widget.user.profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.person, color: Colors.white70, size: 50))
                        : const Icon(Icons.person,
                            color: Colors.white70, size: 50),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFBE1373),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String label, required Widget child}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF555555),
                  letterSpacing: 1.5)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('INTERESTS',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF555555),
                      letterSpacing: 1.5)),
              Text('${_selectedInterests.length} selected',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFBE1373),
                      fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allInterests.map((interest) {
              final selected = _selectedInterests.contains(interest);
              return GestureDetector(
                onTap: () => setState(() {
                  if (selected) {
                    _selectedInterests.remove(interest);
                  } else {
                    _selectedInterests.add(interest);
                  }
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFBE1373)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected
                            ? const Color(0xFFBE1373)
                            : const Color(0xFFDDDDDD)),
                  ),
                  child: Text(interest,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF555555))),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFFBE1373), width: 1.5)),
        counterStyle:
            const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
      );
}
