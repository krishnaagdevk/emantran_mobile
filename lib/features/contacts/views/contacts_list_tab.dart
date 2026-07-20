import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/frameless_text_field.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/api_repository.dart';
import 'add_edit_contact_screen.dart';

class ContactsListTab extends StatefulWidget {
  const ContactsListTab({super.key});

  @override
  State<ContactsListTab> createState() => _ContactsListTabState();
}

class _ContactsListTabState extends State<ContactsListTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _expandedContactId;

  // Controllers for adding contacts
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'Colleagues';

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddContactBottomSheet() {
    final repo = Provider.of<ApiRepository>(context, listen: false);
    final domain = repo.currentRoom?.domain ?? repo.currentUser?.domain ?? 'emantra.app';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 38,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.faint.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Add Contact',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontSize: 22,
                            ),
                      ),
                      const SizedBox(height: 18),

                      FramelessTextField(
                        labelText: 'full name',
                        hintText: 'John Doe',
                        controller: _nameController,
                      ),
                      const SizedBox(height: 18),

                      FramelessTextField(
                        labelText: 'email',
                        hintText: 'john.doe@$domain',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),

                      FramelessTextField(
                        labelText: 'phone number',
                        hintText: '+1 (555) 000-1122',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 18),

                      FramelessTextField(
                        labelText: 'internal notes',
                        hintText: 'Notes regarding interaction preferences...',
                        controller: _notesController,
                      ),
                      const SizedBox(height: 18),

                      // Category selection row
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CATEGORY:',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: ['Colleagues', 'VIP', 'Friends', 'Family'].map((cat) {
                              final active = _selectedCategory == cat;
                              return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    _selectedCategory = cat;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: active ? AppColors.violet : AppColors.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: active ? Colors.transparent : AppColors.border,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 11,
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

                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: () {
                          final name = _nameController.text.trim();
                          final email = _emailController.text.trim();
                          if (name.isNotEmpty && email.isNotEmpty) {
                            final repo = Provider.of<ApiRepository>(context, listen: false);
                            repo.addContact(
                              name: name,
                              email: email,
                              phone: _phoneController.text.trim(),
                              notes: _notesController.text.trim(),
                              category: _selectedCategory,
                            );

                            // Clear Controllers
                            _nameController.clear();
                            _emailController.clear();
                            _phoneController.clear();
                            _notesController.clear();

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Contact "$name" successfully added!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                        child: const Text('Save contact'),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    
    // Sort and filter contacts A-Z
    final filteredContacts = repo.contacts.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Title Header & Plus trigger
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contacts',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.violet, size: 28),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditContactScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // 2. Search Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 15, color: AppColors.ink),
                    decoration: const InputDecoration(
                      hintText: 'Search contacts by name...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    child: const Icon(Icons.close_rounded, color: AppColors.muted, size: 18),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 3. Contacts A-Z Listing
        Expanded(
          child: filteredContacts.isEmpty
              ? const Center(
                  child: Text(
                    'No contacts found.',
                    style: TextStyle(fontFamily: 'Outfit', color: AppColors.muted),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    final isExpanded = _expandedContactId == contact.id;

                    // Group Pill Colors mapping
                    Color tagBg = AppColors.primary.withOpacity(0.06);
                    Color tagText = AppColors.primary;
                    if (contact.category == 'VIP') {
                      tagBg = AppColors.cta.withOpacity(0.08);
                      tagText = AppColors.cta;
                    } else if (contact.category == 'Friends') {
                      tagBg = AppColors.violet.withOpacity(0.08);
                      tagText = AppColors.violet;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isExpanded ? AppColors.violet : AppColors.border,
                          width: isExpanded ? 1.5 : 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x021E1B1A),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Base Header Row
                          Material(
                            color: Colors.transparent,
                            child: ListTile(
                              onTap: () {
                                setState(() {
                                  _expandedContactId = isExpanded ? null : contact.id;
                                });
                              },
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary.withOpacity(0.08),
                                child: Text(
                                  contact.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'Outfit',
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              title: Text(
                                contact.name,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                contact.email,
                                style: const TextStyle(
                                  fontFamily: 'Outfit',
                                  color: AppColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: tagBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  contact.category.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: tagText,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Expanding Contact Detail Card
                          if (isExpanded)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              color: AppColors.primary.withOpacity(0.02),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(color: AppColors.border, height: 1),
                                  const SizedBox(height: 12),
                                  
                                  // Detail row: phone
                                  Row(
                                    children: [
                                      const Icon(Icons.phone_outlined, color: AppColors.muted, size: 16),
                                      const SizedBox(width: 10),
                                      Text(
                                        contact.phone.isNotEmpty ? contact.phone : 'No phone registered',
                                        style: const TextStyle(
                                          fontFamily: 'JetBrains Mono',
                                          fontSize: 13,
                                          color: AppColors.ink,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Detail row: notes
                                  if (contact.notes.isNotEmpty) ...[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.sticky_note_2_outlined, color: AppColors.muted, size: 16),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            contact.notes,
                                            style: const TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 13,
                                              color: AppColors.muted,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                  ],

                                  // Core Action Icons (Envelope / Phone calls shortcut)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Edit Contact Icon Button
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.violet, size: 18),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => AddEditContactScreen(contact: contact),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      // SMS/Phone Icon Button
                                      IconButton(
                                        icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.violet, size: 18),
                                        onPressed: () {},
                                      ),
                                      const SizedBox(width: 4),
                                      IconButton(
                                        icon: const Icon(Icons.email_outlined, color: AppColors.violet, size: 18),
                                        onPressed: () {},
                                      ),
                                      const SizedBox(width: 4),
                                      // Delete contact icon
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
                                        onPressed: () {
                                          repo.deleteContact(contact.id);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Contact successfully deleted'),
                                              backgroundColor: AppColors.danger,
                                              duration: Duration(seconds: 1),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
