import 'package:flutter/material.dart';
import 'dart:io';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  final MaintenanceIssue issue;

  const MaintenanceDetailScreen({super.key, required this.issue});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? PamodziColors.bgDark : PamodziColors.bg;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;
    final text2Color = isDark ? PamodziColors.text2Dark : PamodziColors.text2;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;

    Color statusColor;
    Color iconBg;
    Color iconFg;
    
    switch (issue.status) {
      case 'progress':
        statusColor = PamodziColors.amber;
        iconBg = PamodziColors.amberGl;
        iconFg = PamodziColors.amber;
        break;
      case 'resolved':
        statusColor = PamodziColors.green;
        iconBg = PamodziColors.greenGl;
        iconFg = PamodziColors.green;
        break;
      default:
        statusColor = PamodziColors.blue;
        iconBg = PamodziColors.blueGl;
        iconFg = PamodziColors.blue;
    }

    Color priorityColor;
    switch (issue.priority) {
      case 'urgent':
        priorityColor = PamodziColors.red;
        break;
      case 'high':
        priorityColor = PamodziColors.amber;
        break;
      case 'medium':
        priorityColor = PamodziColors.blue;
        break;
      default:
        priorityColor = PamodziColors.green;
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(title: 'Issue Details'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Issue header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: iconBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  issueIcon(issue.iconType),
                                  color: iconFg,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      issue.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        IssueStatusChip(status: issue.status),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: priorityColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: priorityColor.withOpacity(0.3),
                                            ),
                                          ),
                                          child: Text(
                                            issue.priority.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: priorityColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Issue details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailRow(
                            label: 'Category',
                            value: issue.category,
                            textColor: textColor,
                            text2Color: text2Color,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: 'Reported',
                            value: issue.date,
                            textColor: textColor,
                            text2Color: text2Color,
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            label: 'Assigned To',
                            value: issue.assignee,
                            textColor: textColor,
                            text2Color: text2Color,
                          ),
                        ],
                      ),
                    ),

                    // Description
                    if (issue.description != null && issue.description!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DESCRIPTION',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: mutedColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              issue.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: text2Color,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Photos
                    if (issue.photoUrls != null && issue.photoUrls!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PHOTOS',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: mutedColor,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: issue.photoUrls!.map((url) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(url),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Action button
                    if (issue.status != 'resolved')
                      PamodziButton(
                        label: 'Contact Landlord About This Issue',
                        icon: Icons.mail_outline,
                        onTap: () => showToast('Contacting landlord...'),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final Color text2Color;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.textColor,
    required this.text2Color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: text2Color,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
