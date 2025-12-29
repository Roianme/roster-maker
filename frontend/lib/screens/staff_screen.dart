import 'package:flutter/material.dart';
import '../models/staff.dart';
import '../models/role.dart';
import '../services/firestore_service.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  final _firestoreService = FirestoreService();

  void _showStaffDialog([Staff? staff]) async {
    final firstNameController = TextEditingController(text: staff?.firstName ?? '');
    final lastNameController = TextEditingController(text: staff?.lastName ?? '');
    final emailController = TextEditingController(text: staff?.email ?? '');
    final formKey = GlobalKey<FormState>();
    
    // Get roles for selection
    final rolesSnapshot = await _firestoreService.getRoles().first;
    final selectedRoleIds = Set<String>.from(staff?.roleIds ?? []);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(staff == null ? 'Add Staff' : 'Edit Staff'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Roles:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...rolesSnapshot.map((role) => CheckboxListTile(
                        title: Text(role.name),
                        value: selectedRoleIds.contains(role.id),
                        onChanged: (checked) {
                          setDialogState(() {
                            if (checked ?? false) {
                              selectedRoleIds.add(role.id);
                            } else {
                              selectedRoleIds.remove(role.id);
                            }
                          });
                        },
                      )),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final newStaff = Staff(
                    id: staff?.id ?? '',
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    email: emailController.text,
                    roleIds: selectedRoleIds.toList(),
                  );
                  if (staff == null) {
                    await _firestoreService.createStaff(newStaff);
                  } else {
                    await _firestoreService.updateStaff(newStaff);
                  }
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Staff>>(
        stream: _firestoreService.getStaff(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final staff = snapshot.data!;
          return ListView.builder(
            itemCount: staff.length,
            itemBuilder: (context, index) {
              final person = staff[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(person.fullName),
                subtitle: Text(person.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showStaffDialog(person),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _firestoreService.deleteStaff(person.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStaffDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
