import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/user_Profiles/profile_bloc.dart';
import '../bloc/user_Profiles/profile_event.dart';
import '../bloc/user_Profiles/profile_state.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _uploading = false;

  
  final List<String> predefinedAvatars = [
    'https://i.pravatar.cc/150?img=1',
    'https://i.pravatar.cc/150?img=2',
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=4',
    'https://i.pravatar.cc/150?img=5',
    'https://i.pravatar.cc/150?img=6',
    'https://i.pravatar.cc/150?img=7',
    'https://i.pravatar.cc/150?img=8',
    'https://i.pravatar.cc/150?img=9',
    'https://i.pravatar.cc/150?img=10',
    'https://i.pravatar.cc/150?img=11',
    'https://i.pravatar.cc/150?img=12',
    'https://i.pravatar.cc/150?img=13',
    'https://i.pravatar.cc/150?img=14',
    'https://i.pravatar.cc/150?img=15',
  ];

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();

    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile == null) return;
if (!mounted) return;
    setState(() {
      _uploading = true;
    });

    try {
      final file = File(pickedFile.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('avatars/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
if (!mounted) return;
      context.read<ProfileBloc>().add(UpdateAvatar(downloadUrl));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  Widget _buildAvatarSelector(String currentAvatarUrl) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: predefinedAvatars.length,
        itemBuilder: (context, index) {
          final avatarUrl = predefinedAvatars[index];
          final isSelected = avatarUrl == currentAvatarUrl;

          return GestureDetector(
            onTap: () {
              context.read<ProfileBloc>().add(UpdateAvatar(avatarUrl));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(
                radius: isSelected ? 35 : 30,
                backgroundColor:
                    isSelected ? Colors.blueAccent : Colors.grey[300],
                child: CircleAvatar(
                  radius: isSelected ? 32 : 27,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('Profile', style: TextStyle(color: Colors.purple[50], fontWeight: FontWeight.bold,
              letterSpacing: .5,)),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent[700],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || _uploading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }

          if (state is ProfileLoaded) {
            final prefs = state.preferences;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: prefs.avatarUrl.isNotEmpty
                                ? NetworkImage(prefs.avatarUrl)
                                : const AssetImage('assets/default_avatar.png')
                                    as ImageProvider,
                          ),
                          FloatingActionButton(
                            mini: true,
                            onPressed: _pickAndUploadImage,
                            child: const Icon(Icons.edit),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                     
                      _buildAvatarSelector(prefs.avatarUrl),

                      const SizedBox(height: 20),

                      Text(
                        'Theme Color',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        value: prefs.themeColor,
                        items: ['blue', 'green', 'red'].map((color) {
                          return DropdownMenuItem<String>(
                            value: color,
                            child: Text(
                              color[0].toUpperCase() + color.substring(1),
                              style: TextStyle(
                                color: _colorFromName(color),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context
                                .read<ProfileBloc>()
                                .add(UpdateThemeColor(value));
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigoAccent[700],
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: Icon(Icons.logout, color: Colors.purple[50]),
                        label: Text('Sign Out', style: TextStyle(fontSize: 18, color: Colors.purple[50])),
                        onPressed: () {
                          context.read<ProfileBloc>().add(SignOutRequested());
                          context.go('/');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
  Color _colorFromName(String name) {
    switch (name) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
