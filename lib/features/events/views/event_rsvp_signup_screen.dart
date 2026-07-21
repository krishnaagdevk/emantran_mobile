import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/atmospheric_blobs.dart';
import '../../../app/widgets/frameless_text_field.dart';
import '../../../app/widgets/status_chip.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/api_repository.dart';
import 'event_rsvp_confirmation_screen.dart';

class EventRSVPSignupScreen extends StatefulWidget {
  const EventRSVPSignupScreen({super.key, required this.event});

  final OrgEvent event;

  @override
  State<EventRSVPSignupScreen> createState() => _EventRSVPSignupScreenState();
}

class _EventRSVPSignupScreenState extends State<EventRSVPSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isAttending = true;

  void _submitRSVP() {
    if (_formKey.currentState!.validate()) {
      final repo = Provider.of<ApiRepository>(context, listen: false);
      repo.addGuest(
        eventId: widget.event.id,
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty 
            ? '${_nameController.text.trim().toLowerCase().replaceAll(' ', '.')}@example.com' 
            : _emailController.text.trim(),
        status: _isAttending ? GuestStatus.accepted : GuestStatus.declined,
        category: 'Self-Registered',
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EventRSVPConfirmationScreen(
            event: widget.event,
            guestName: _nameController.text.trim(),
            isAttending: _isAttending,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ApiRepository>(context);
    final domain = repo.currentRoom?.domain ?? repo.currentUser?.domain ?? 'emantra.app';

    return AtmosphericBlobs(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Confirm your entry',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RSVP to: ${widget.event.title}',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    color: AppColors.muted,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 24),

                // Link/Invitation Validity tag
                Row(
                  children: [
                    Text(
                      'LINK VALIDITY:',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'ACTIVE & CONFIRMED',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          color: AppColors.success,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // RSVP form card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x041E1B1A),
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name Input
                        FramelessTextField(
                          labelText: 'your name',
                          hintText: 'John Doe',
                          controller: _nameController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Email Input
                        FramelessTextField(
                          labelText: 'your corporate email',
                          hintText: 'john.doe@$domain',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || !val.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Toggle Buttons: Attending vs Declined
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RSVP SELECTION:',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.muted.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                // Attending
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isAttending = true;
                                      });
                                    },
                                    child: Container(
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: _isAttending ? AppColors.success : AppColors.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _isAttending ? Colors.transparent : AppColors.border,
                                          width: 1.2,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'ATTENDING',
                                        style: TextStyle(
                                          fontFamily: 'JetBrains Mono',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: _isAttending ? Colors.white : AppColors.muted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Declined
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isAttending = false;
                                      });
                                    },
                                    child: Container(
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: !_isAttending ? AppColors.danger : AppColors.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: !_isAttending ? Colors.transparent : AppColors.border,
                                          width: 1.2,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'DECLINING',
                                        style: TextStyle(
                                          fontFamily: 'JetBrains Mono',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: !_isAttending ? Colors.white : AppColors.muted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 36),

                        // Action Submit Button (Coral Pill)
                        ElevatedButton(
                          onPressed: _submitRSVP,
                          child: const Text('Confirm RSVP'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
