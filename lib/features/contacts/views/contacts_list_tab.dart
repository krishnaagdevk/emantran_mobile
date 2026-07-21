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
  String _selectedCategory = ContactCategories.colleague;

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
                           Wrap(
                             spacing: 8,
                             runSpacing: 8,
                             children: ContactCategories.values.map((cat) {
                               final active = _selectedCategory == cat;
                               return GestureDetector(
                                 onTap: () {
                                   setModalState(() {
                                     _selectedCategory = cat;
                                   });
                                 },
                                 child: Container(
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

  void _showImportExcelSimulationDialog() {
    final repo = Provider.of<ApiRepository>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        int activeStep = 0; // 0: Upload Zone, 1: File Explorer, 2: Upload progress, 3: Parsing/Success
        String selectedFileName = '';
        double uploadProgress = 0.0;
        String currentStatusText = 'Uploading...';
        List<Map<String, String>> contactsToImport = [];

        final deviceFiles = [
          {
            'name': 'employee_roster_2026.xlsx',
            'type': 'Excel Spreadsheet',
            'size': '154 KB',
            'isValid': true,
            'contacts': [
              {'name': 'Bill Gates', 'email': 'bill.gates@microsoft.com', 'phone': '+1-555-0201', 'notes': 'Co-founder of Microsoft.', 'category': 'VIP'},
              {'name': 'Melinda French', 'email': 'melinda.french@gates.org', 'phone': '+1-555-0202', 'notes': 'Philanthropist.', 'category': 'VIP'},
              {'name': 'Paul Allen', 'email': 'paul.allen@vulcan.com', 'phone': '+1-555-0203', 'notes': 'Co-founder of Microsoft.', 'category': 'Colleague'},
            ]
          },
          {
            'name': 'client_directory.csv',
            'type': 'CSV Text File',
            'size': '82 KB',
            'isValid': true,
            'contacts': [
              {'name': 'Tim Berners-Lee', 'email': 'timbl@w3.org', 'phone': '+1-555-0204', 'notes': 'Inventor of the World Wide Web.', 'category': 'VIP'},
              {'name': 'Marc Andreessen', 'email': 'marc@a16z.com', 'phone': '+1-555-0205', 'notes': 'Co-author of Mosaic.', 'category': 'VIP'},
              {'name': 'Brendan Eich', 'email': 'brendan@brave.com', 'phone': '+1-555-0206', 'notes': 'Creator of JavaScript.', 'category': 'Colleague'},
            ]
          },
          {
            'name': 'self_portrait_hd.png',
            'type': 'PNG Image File',
            'size': '4.2 MB',
            'isValid': false,
            'contacts': <Map<String, String>>[]
          },
          {
            'name': 'financial_lease_agreement.pdf',
            'type': 'Adobe PDF Document',
            'size': '2.1 MB',
            'isValid': false,
            'contacts': <Map<String, String>>[]
          }
        ];

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // STEP 0: Landing Drag & Drop simulated area
            if (activeStep == 0) {
              return AlertDialog(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Row(
                  children: [
                    Icon(Icons.file_present_rounded, color: AppColors.cta, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Upload Spreadsheet',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Invite colleagues in bulk by dragging or selecting your invitation sheet.',
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 20),
                    
                    // Large dashed interaction area
                    GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          activeStep = 1; // Slide to File Explorer Simulation
                        });
                      },
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.cta.withOpacity(0.4),
                            width: 1.5,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.cta.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.cloud_upload_outlined, color: AppColors.cta, size: 24),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Browse spreadsheet files',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Supports Excel (.xlsx) or CSV format',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 11,
                                  color: AppColors.muted.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(fontFamily: 'Outfit', color: AppColors.muted)),
                  ),
                ],
              );
            }

            // STEP 1: Simulated Device File Explorer Overlay
            if (activeStep == 1) {
              return AlertDialog(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.muted),
                      onPressed: () {
                        setDialogState(() {
                          activeStep = 0;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'Device Storage: /Downloads',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Tap a valid spreadsheet template to choose and upload:',
                          style: TextStyle(fontFamily: 'Outfit', fontSize: 12, color: AppColors.muted),
                        ),
                      ),
                      ...deviceFiles.map((f) {
                        final name = f['name'] as String;
                        final type = f['type'] as String;
                        final size = f['size'] as String;
                        final isValid = f['isValid'] as bool;
                        final contacts = f['contacts'] as List<Map<String, String>>;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isValid ? AppColors.canvas : Colors.red.withOpacity(0.01),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isValid ? AppColors.border : Colors.red.withOpacity(0.12),
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              if (!isValid) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invalid file format! Please upload an Excel or CSV file.'),
                                    backgroundColor: AppColors.danger,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                                return;
                              }

                              setDialogState(() {
                                selectedFileName = name;
                                contactsToImport = contacts;
                                activeStep = 2; // Move to upload animation
                                uploadProgress = 0.0;
                                currentStatusText = 'Connecting to server...';
                              });

                              // Simulate incremental upload percentage!
                              int tick = 0;
                              Future.doWhile(() async {
                                await Future.delayed(const Duration(milliseconds: 250));
                                tick++;
                                if (tick == 2) currentStatusText = 'Uploading $name ($size)...';
                                if (tick == 5) currentStatusText = 'Upload complete. Checking server checksums...';
                                if (tick == 7) currentStatusText = 'Validating columns and matching email scopes...';

                                setDialogState(() {
                                  uploadProgress = (tick / 8.0).clamp(0.0, 1.0);
                                });

                                if (tick >= 8) {
                                  // Perform insertion!
                                  for (final c in contactsToImport) {
                                    repo.addContact(
                                      name: c['name']!,
                                      email: c['email']!,
                                      phone: c['phone']!,
                                      notes: c['notes']!,
                                      category: c['category']!,
                                    );
                                  }

                                  Navigator.pop(context); // Close dialog
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Successfully imported ${contactsToImport.length} contacts from $name!',
                                              style: const TextStyle(fontFamily: 'Outfit', fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                  return false; // Stop loop
                                }
                                return true; // Continue loop
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // File icon
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: !isValid
                                          ? Colors.red.withOpacity(0.08)
                                          : (name.endsWith('.xlsx')
                                              ? Colors.green.withOpacity(0.08)
                                              : Colors.blue.withOpacity(0.08)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      !isValid
                                          ? Icons.error_outline_rounded
                                          : (name.endsWith('.xlsx')
                                              ? Icons.table_view_rounded
                                              : Icons.description_rounded),
                                      color: !isValid
                                          ? Colors.red
                                          : (name.endsWith('.xlsx') ? Colors.green : Colors.blue),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontFamily: 'Outfit',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: isValid ? AppColors.ink : AppColors.muted,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$type · $size',
                                          style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, color: AppColors.muted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isValid)
                                    const Icon(Icons.lock_clock_rounded, color: Colors.grey, size: 14)
                                  else
                                    const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 16),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }

            // STEP 2: Upload Progression Bar
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dynamic upload loader circle with progress text inside!
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            value: uploadProgress,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cta),
                            strokeWidth: 4,
                          ),
                        ),
                        Text(
                          '${(uploadProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.cta,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      currentStatusText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Establishing secure stream, parsing Excel binary indexes...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.file_present_rounded, color: AppColors.cta, size: 26),
                    tooltip: 'Import Excel/CSV',
                    onPressed: _showImportExcelSimulationDialog,
                  ),
                  const SizedBox(width: 4),
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
                    final catUpper = contact.category.toUpperCase();
                    if (catUpper == 'VIP' || catUpper == 'VVIP') {
                      tagBg = AppColors.cta.withOpacity(0.08);
                      tagText = AppColors.cta;
                    } else if (catUpper == 'FRIEND' || catUpper == 'FRIENDS') {
                      tagBg = AppColors.violet.withOpacity(0.08);
                      tagText = AppColors.violet;
                    } else if (catUpper == 'FAMILY' || catUpper == "BRIDE'S FAMILY" || catUpper == "GROOM'S FAMILY") {
                      tagBg = Colors.pink.withOpacity(0.08);
                      tagText = Colors.pink;
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
