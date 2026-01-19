import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../services/profile_service.dart';
import '../models/user.dart' as app_user;

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isPickingImage = false;
  app_user.User? _currentUser;
  String? _localProfilePicture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLocalProfilePicture();
  }

  Future<void> _loadUserData() async {
    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final user = await profileService.getUserProfileOnce(uid);
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.name;
          _emailController.text = user.email;
          _phoneController.text = user.phone ?? '';
        });
      }
    }
  }

  Future<void> _loadLocalProfilePicture() async {
    try {
      final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // Get the temp directory for profile pictures
        final tempDir = Directory.systemTemp;
        final profileDir = Directory('${tempDir.path}/chikibite_profile_pictures');
        final profileImageFile = File('${profileDir.path}/$uid.jpg');

        if (profileImageFile.existsSync()) {
          if (mounted) {
            setState(() {
              _localProfilePicture = profileImageFile.path;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading local profile picture: $e');
    }
  }

  Future<void> _pickProfilePicture() async {
    // Prevent multiple concurrent image picker calls
    if (_isPickingImage) return;
    
    try {
      _isPickingImage = true;
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          // Create profile-picture directory in temp
          final tempDir = Directory.systemTemp;
          final profileDir = Directory('${tempDir.path}/chikibite_profile_pictures');
          
          if (!profileDir.existsSync()) {
            profileDir.createSync(recursive: true);
          }

          // Save the image
          final File imageFile = File(pickedFile.path);
          final fileName = '$uid.jpg';
          final savedImage = await imageFile.copy('${profileDir.path}/$fileName');

          if (mounted) {
            setState(() {
              _localProfilePicture = savedImage.path;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading picture: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await profileService.updatePersonalInfo(
          uid: uid,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Picture
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.orange[300]!,
                                width: 3,
                              ),
                            ),
                            child: _localProfilePicture != null
                                ? ClipOval(
                                    child: Image.file(
                                      File(_localProfilePicture!),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Colors.orange[800],
                                            );
                                          },
                                    ),
                                  )
                                : _currentUser?.photoUrl != null
                                    ? ClipOval(
                                        child: Image.network(
                                          _currentUser!.photoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Colors.orange[800],
                                                );
                                              },
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.orange[800],
                                      ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.orange[700],
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                onPressed: _pickProfilePicture,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.orange[700]!,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field (Read-only)
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email cannot be changed',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.orange[700]!,
                            width: 2,
                          ),
                        ),
                        hintText: 'Optional',
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[700],
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
