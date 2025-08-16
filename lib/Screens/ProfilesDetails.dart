import 'package:flutter/material.dart';

class ProfileDetailsPage extends StatelessWidget {
  final Map<String, dynamic> profile;

  const ProfileDetailsPage({Key? key, required this.profile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Show Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundImage: profile['profile_pic'] != null
                  ? NetworkImage(profile['profile_pic'])
                  : null,
              child: profile['profile_pic'] == null
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
            const SizedBox(height: 20),

            // Show Name
            Text(
              profile['name'] ?? 'No Name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Show Father Name
            Text("Father Name: ${profile['father_name'] ?? ''}"),
            const SizedBox(height: 10),

            // Show DOB
            Text("DOB: ${profile['dob'] ?? ''}"),
            const SizedBox(height: 10),

            // Show Gender
            Text("Gender: ${profile['gender'] ?? ''}"),
            Text("Time : ${profile['created_at'] ?? ''}"),
          ],
        ),
      ),
    );
  }
}
