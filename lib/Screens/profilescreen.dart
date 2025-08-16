import 'dart:io';
import 'package:camera_usage/Screens/ProfilesDetails.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({Key? key}) : super(key: key);

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  String? gender;
  File? profileImage;
  String? profileImageUrl; // For network image from Supabase
  String? time;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        dobController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    String? imageUrl = profileImageUrl;

    try {
      // If user picked a new image, upload it
      if (profileImage != null) {
        final fileExt = profileImage!.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = 'profile-pics/$fileName';

        // Upload image to Supabase storage
        await supabase.storage.from('profile-pics').upload(
              filePath,
              profileImage!,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );

        // Get the public URL
        imageUrl = supabase.storage.from('profile-pics').getPublicUrl(filePath);
      }

      // Save profile data in table
      await supabase.from('ProfilesData').insert({
        'name': nameController.text,
        'father_name': fatherNameController.text,
        'dob': dobController.text,
        'gender': gender,
        'profile_pic': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully!")),
      );

      _fetchProfile(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      if (kDebugMode) {
        print("ERROR WHILE SAVING THE PROFILE DATA: $e");
      }
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await supabase
          .from('ProfilesData')
          .select()
          .order('id', ascending: false)
          .limit(1);
      if (kDebugMode) {
        print("RESPONSE: $response");
      }
      if (response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No profile found.")),
        );
        return;
      }
      if (response.isNotEmpty) {
        final profile = response.first;

        setState(() {
          nameController.text = profile['name'] ?? '';
          fatherNameController.text = profile['father_name'] ?? '';
          dobController.text = profile['dob'] ?? '';
          gender = profile['gender'];
          profileImageUrl = profile['profile_pic'];
          profileImage = null;
          time = DateTime.now().toIso8601String();
        });
        if (kDebugMode) {
          print("PROFILE Fetched SUCCESSFULLY: $profileImageUrl");
          print("COMPLETE PROFILE : $profile");
        }

        // 👉 Navigate to new screen and show profile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileDetailsPage(profile: profile),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Form"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : (profileImageUrl != null
                            ? NetworkImage(profileImageUrl!) as ImageProvider
                            : null),
                    child: (profileImage == null && profileImageUrl == null)
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter your name" : null,
                ),
                const SizedBox(height: 15),

                // Father Name
                TextFormField(
                  controller: fatherNameController,
                  decoration: const InputDecoration(
                    labelText: "Father Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter your father name" : null,
                ),
                const SizedBox(height: 15),

                // Date of Birth
                TextFormField(
                  controller: dobController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: "Date of Birth",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) => value!.isEmpty
                      ? "Please select your date of birth"
                      : null,
                ),
                const SizedBox(height: 15),

                // Gender
                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(),
                  ),
                  items: ["Male", "Female", "Other"]
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Please select your gender" : null,
                ),
                const SizedBox(height: 25),

                // Save Button
                ElevatedButton(
                  onPressed: () {
                    _saveProfile().then((value) {
                      if (kDebugMode) {
                        print("IMAGE SAVE SUCCESSFULLY");
                      }
                      // Optionally, you can navigate to another page or show a success message
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $error")),
                      );

                      if (kDebugMode) {
                        print("ERROR WHILE SAVING THE PROFILE DATA: $error");
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Save Profile"),
                ),

                ElevatedButton(
                  onPressed: () {
                    _fetchProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text("Show Profile"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
