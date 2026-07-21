import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/frameless_text_field.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/api_repository.dart';

class AddEditContactScreen extends StatefulWidget {
  const AddEditContactScreen({super.key, this.contact});

  final AppContact? contact;

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = ContactCategories.colleague;

  bool get _isEditMode => widget.contact != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final c = widget.contact!;
      _nameController.text = c.name;
      _emailController.text = c.email;
      _phoneController.text = c.phone;
      _notesController.text = c.notes;
      
      String category = c.category;
      if (category == 'Colleagues') category = 'Colleague';
      if (category == 'Friends') category = 'Friend';
      _selectedCategory = category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final repo = Provider.of<ApiRepository>(context, listen: false);
      if (_isEditMode) {
        repo.editContact(
          id: widget.contact!.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          notes: _notesController.text.trim(),
          category: _selectedCategory,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact updated successfully'), backgroundColor: AppColors.success),
        );
      } else {
        repo.addContact(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          notes: _notesController.text.trim(),
          category: _selectedCategory,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact added successfully'), backgroundColor: AppColors.success),
        );
      }
      Navigator.pop(context);
    }
  }

  void _delete() {
    if (_isEditMode) {
      final repo = Provider.of<ApiRepository>(context, listen: false);
      repo.deleteContact(widget.contact!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact deleted'), backgroundColor: AppColors.danger),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    final domain = repo.currentRoom?.domain ?? repo.currentUser?.domain ?? 'emantra.app';

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.primary, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? 'Edit Contact' : 'New Contact',
          style: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Avatar with Coral Camera Badge
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primary.withOpacity(0.06),
                        child: Text(
                          _nameController.text.isNotEmpty 
                              ? _nameController.text.substring(0,1).toUpperCase() 
                              : '?',
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w800,
                            fontSize: 32,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: AppColors.cta, // Coral camera indicator
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 2. Form card with Frameless Fields
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      FramelessTextField(
                        labelText: 'full name',
                        hintText: 'Johnathan Doe',
                        controller: _nameController,
                        onChanged: (val) {
                          setState(() {}); // refresh avatar letter
                        },
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Please enter a name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      FramelessTextField(
                        labelText: 'email address',
                        hintText: 'johnathan@$domain',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || !val.contains('@')) return 'Please enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      FramelessTextField(
                        labelText: 'phone number',
                        hintText: '+1 (555) 019-2831',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 18),
                      FramelessTextField(
                        labelText: 'biographical notes',
                        hintText: 'Notes regarding interaction, role details...',
                        controller: _notesController,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Category selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CONTACT CATEGORY GROUP:',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                     Wrap(
                       spacing: 8,
                       runSpacing: 8,
                       children: ContactCategories.values.map((cat) {
                         final active = _selectedCategory == cat;
                         return GestureDetector(
                           onTap: () {
                             setState(() {
                               _selectedCategory = cat;
                             });
                           },
                           child: Container(
                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                             decoration: BoxDecoration(
                               color: active ? AppColors.violet : AppColors.surface,
                               borderRadius: BorderRadius.circular(10),
                               border: Border.all(
                                 color: active ? Colors.transparent : AppColors.border,
                                 width: 1.2,
                               ),
                             ),
                             child: Text(
                               cat,
                               style: TextStyle(
                                 fontFamily: 'Outfit',
                                 fontSize: 12,
                                 fontWeight: FontWeight.w700,
                                 color: active ? Colors.white : AppColors.muted,
                               ),
                             ),
                           ),
                         );
                       }).toList(),
                     ),
                  ],
                ),

                const SizedBox(height: 44),

                // Save Contact CTA (Coral Pill)
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save Contact'),
                ),

                if (_isEditMode) ...[
                  const SizedBox(height: 14),
                  // Delete Contact Red button
                  OutlinedButton(
                    onPressed: _delete,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.danger, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Delete Contact',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
