import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/split_pill_date_selector.dart';
import '../../../app/widgets/frameless_text_field.dart';
import '../../../data/repositories/api_repository.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _hostController = TextEditingController();
  final _venueController = TextEditingController();
  final _notesController = TextEditingController();
  final _priceController = TextEditingController(text: '10.00');

  bool _isFree = true;
  bool _isPublishing = false;
  DateTime _selectedDateTime = DateTime.now().add(const Duration(days: 1)); // Default to tomorrow

  String get _selectedDateText {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final day = _selectedDateTime.day.toString().padLeft(2, '0');
    final monthStr = months[_selectedDateTime.month - 1];
    return '$day $monthStr';
  }

  String get _selectedTimeText {
    final hourRaw = _selectedDateTime.hour;
    final hour = hourRaw % 12 == 0 ? 12 : hourRaw % 12;
    final minute = _selectedDateTime.minute.toString().padLeft(2, '0');
    final amPm = hourRaw >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $amPm';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hostController.dispose();
    _venueController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _showDatePickerModal() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                onSurface: AppColors.primary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _publishEvent() async {
    if (_formKey.currentState!.validate() && !_isPublishing) {
      setState(() {
        _isPublishing = true;
      });

      final repo = Provider.of<ApiRepository>(context, listen: false);
      final host = _hostController.text.trim().isEmpty 
          ? (repo.currentUser?.name ?? 'Workspace Admin') 
          : _hostController.text.trim();

      try {
        await repo.createEvent(
          title: _titleController.text.trim(),
          host: host,
          dateText: _selectedDateText,
          timeText: _selectedTimeText,
          venue: _venueController.text.trim(),
          notes: _notesController.text.trim(),
          price: _isFree ? 0.0 : (double.tryParse(_priceController.text) ?? 0.0),
          isFree: _isFree,
          isoDate: _selectedDateTime.toUtc().toIso8601String(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Event "${_titleController.text}" published successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context); // Close the fullscreen overlay dialog
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to publish event: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isPublishing = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    final roomName = repo.currentRoom?.name ?? 'Emantra Workspace';

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
          'Create Event',
          style: TextStyle(
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Date Selector pill row (Signature split-pill)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EVENT DATE:',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted.withOpacity(0.8),
                      ),
                    ),
                    SplitPillDateSelector(
                      selectedDateText: _selectedDateText,
                      onTap: _showDatePickerModal,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Main Form Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border, width: 1.2),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Event Title
                      FramelessTextField(
                        labelText: 'event title',
                        hintText: 'Annual Gala / Launch Party',
                        controller: _titleController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Host Name
                      FramelessTextField(
                        labelText: 'host coordinator',
                        hintText: '$roomName (Default)',
                        controller: _hostController,
                      ),
                      const SizedBox(height: 20),

                      // Location / Venue
                      FramelessTextField(
                        labelText: 'venue location',
                        hintText: 'The Regency Ballroom, SF',
                        controller: _venueController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter a venue';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Short notes / description
                      FramelessTextField(
                        labelText: 'invitation description notes',
                        hintText: 'Describe details, parameters, entry guidelines...',
                        controller: _notesController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please write event notes';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Toggle row: Free vs Paid
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'FREE ENTRY:',
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted.withOpacity(0.8),
                            ),
                          ),
                          Switch.adaptive(
                            value: _isFree,
                            activeColor: AppColors.cta,
                            activeTrackColor: AppColors.cta.withOpacity(0.3),
                            onChanged: (val) {
                              setState(() {
                                _isFree = val;
                              });
                            },
                          ),
                        ],
                      ),

                      // If Paid, show price text field
                      if (!_isFree) ...[
                        const SizedBox(height: 16),
                        FramelessTextField(
                          labelText: 'ticket price (\$)',
                          hintText: '10.00',
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (val) {
                            if (val == null || double.tryParse(val) == null) {
                              return 'Please enter a valid price amount';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 36),

                // Action Publish Button (Coral Pill)
                ElevatedButton(
                  onPressed: _isPublishing ? null : _publishEvent,
                  child: _isPublishing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Publish event'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
