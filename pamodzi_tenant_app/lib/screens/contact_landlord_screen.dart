import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/communication_service.dart';

class ContactLandlordScreen extends StatelessWidget {
  const ContactLandlordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final communicationService = CommunicationService();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? PamodziColors.bgDark : PamodziColors.bg;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;
    final text2Color = isDark ? PamodziColors.text2Dark : PamodziColors.text2;
    final greenColor = isDark ? PamodziColors.greenDark2 : PamodziColors.green;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(title: 'Contact Landlord'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Landlord info card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [greenColor, PamodziColors.greenDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                state.lease.landlord.split(' ').map((n) => n[0]).join(''),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.lease.landlord,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Property Owner',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: text2Color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'CONTACT METHODS',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? PamodziColors.mutedDark : PamodziColors.muted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Email
                    _ContactMethodTile(
                      icon: Icons.mail_outline,
                      iconBg: PamodziColors.greenGl,
                      iconColor: greenColor,
                      title: 'Send Email',
                      subtitle: state.lease.landlordEmail,
                      onTap: () async {
                        final success = await communicationService.sendEmail(
                          recipientEmail: state.lease.landlordEmail,
                          subject: 'Inquiry from ${state.tenant.name} - ${state.tenant.unit}',
                          body: 'Hello ${state.lease.landlord},\n\n',
                        );
                        if (!success) {
                          if (context.mounted) {
                            showToast('Could not open email app');
                          }
                        }
                      },
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      text2Color: text2Color,
                    ),
                    const SizedBox(height: 10),

                    // Phone Call
                    _ContactMethodTile(
                      icon: Icons.phone_outlined,
                      iconBg: PamodziColors.blueGl,
                      iconColor: PamodziColors.blue,
                      title: 'Phone Call',
                      subtitle: '+260 977 555 123',
                      onTap: () async {
                        final success = await communicationService.makePhoneCall('+260977555123');
                        if (!success) {
                          if (context.mounted) {
                            showToast('Could not open phone dialer');
                          }
                        }
                      },
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      text2Color: text2Color,
                    ),
                    const SizedBox(height: 10),

                    // SMS
                    _ContactMethodTile(
                      icon: Icons.sms_outlined,
                      iconBg: PamodziColors.amberGl,
                      iconColor: PamodziColors.amber,
                      title: 'Send SMS',
                      subtitle: '+260 977 555 123',
                      onTap: () async {
                        final success = await communicationService.sendSMS(
                          phoneNumber: '+260977555123',
                          message: 'Hello ${state.lease.landlord}, this is ${state.tenant.name} from ${state.tenant.unit}. ',
                        );
                        if (!success) {
                          if (context.mounted) {
                            showToast('Could not open SMS app');
                          }
                        }
                      },
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      text2Color: text2Color,
                    ),
                    const SizedBox(height: 10),

                    // WhatsApp
                    _ContactMethodTile(
                      icon: Icons.chat_bubble_outline,
                      iconBg: const Color(0xFFDCF8C6),
                      iconColor: const Color(0xFF25D366),
                      title: 'WhatsApp Message',
                      subtitle: 'Chat on WhatsApp',
                      onTap: () async {
                        final success = await communicationService.openWhatsApp(
                          phoneNumber: '+260977555123',
                          message: 'Hello ${state.lease.landlord}, this is ${state.tenant.name} from ${state.tenant.unit}.',
                        );
                        if (!success) {
                          if (context.mounted) {
                            showToast('Could not open WhatsApp');
                          }
                        }
                      },
                      surfaceColor: surfaceColor,
                      borderColor: borderColor,
                      textColor: textColor,
                      text2Color: text2Color,
                    ),

                    const SizedBox(height: 24),

                    // Quick message templates
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QUICK MESSAGE TEMPLATES',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? PamodziColors.mutedDark : PamodziColors.muted,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _TemplateChip(
                            label: 'Request maintenance',
                            onTap: () => showToast('Opening maintenance form...'),
                          ),
                          const SizedBox(height: 8),
                          _TemplateChip(
                            label: 'Payment confirmation query',
                            onTap: () => showToast('Opening email with payment query...'),
                          ),
                          const SizedBox(height: 8),
                          _TemplateChip(
                            label: 'Lease renewal inquiry',
                            onTap: () => showToast('Opening email with lease inquiry...'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactMethodTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final VoidCallback onTap;
  final Color surfaceColor, borderColor, textColor, text2Color;

  const _ContactMethodTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.text2Color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: text2Color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: text2Color),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TemplateChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? PamodziColors.bgDark : PamodziColors.bg;
    final text2Color = isDark ? PamodziColors.text2Dark : PamodziColors.text2;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.mail_outline, size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: text2Color,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward, size: 14),
          ],
        ),
      ),
    );
  }
}
