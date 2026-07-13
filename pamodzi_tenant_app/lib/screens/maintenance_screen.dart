import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../data/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import '../services/image_service.dart';
import 'maintenance_detail_screen.dart';

// ── MAINTENANCE LIST ──────────────────────────────────────────────────────────
class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? PamodziColors.bgDark : PamodziColors.bg;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;
    final greenColor = isDark ? PamodziColors.greenDark2 : PamodziColors.green;

    final List<MaintenanceIssue> filtered = _filter == 'all'
        ? state.issues
        : state.issues.where((i) => i.status == _filter).toList();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              title: 'Maintenance Requests',
              trailing: Material(
                color: greenColor,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, a, __) => const NewMaintenanceScreen(),
                      transitionsBuilder: (_, a, __, child) => SlideTransition(
                        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                            .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                        child: child,
                      ),
                      transitionDuration: const Duration(milliseconds: 220),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('New', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Filter chips
            Container(
              color: bgColor,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(label: 'All', value: 'all', selected: _filter, onTap: () => setState(() => _filter = 'all')),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Open', value: 'open', selected: _filter, onTap: () => setState(() => _filter = 'open'), color: PamodziColors.blue),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'In Progress', value: 'progress', selected: _filter, onTap: () => setState(() => _filter = 'progress'), color: PamodziColors.amber),
                    const SizedBox(width: 8),
                    _FilterChip(label: 'Resolved', value: 'resolved', selected: _filter, onTap: () => setState(() => _filter = 'resolved'), color: PamodziColors.green),
                  ],
                ),
              ),
            ),

            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, color: mutedColor, size: 48),
                          const SizedBox(height: 12),
                          Text('No issues in this category', style: TextStyle(color: mutedColor, fontSize: 14)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _IssueCard(issue: filtered[i], surfaceColor: surfaceColor, borderColor: borderColor),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, value, selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({required this.label, required this.value, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = value == selected;
    final activeColor = color ?? (isDark ? PamodziColors.greenDark2 : PamodziColors.green);
    final surface2 = isDark ? PamodziColors.surface2Dark : PamodziColors.surface2;
    final text2Color = isDark ? PamodziColors.text2Dark : PamodziColors.text2;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : surface2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? activeColor.withOpacity(0.4) : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? activeColor : text2Color,
          ),
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final MaintenanceIssue issue;
  final Color surfaceColor, borderColor;

  const _IssueCard({required this.issue, required this.surfaceColor, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;

    Color iconBg;
    Color iconFg;
    switch (issue.status) {
      case 'progress':
        iconBg = PamodziColors.amberGl;
        iconFg = PamodziColors.amber;
        break;
      case 'resolved':
        iconBg = PamodziColors.greenGl;
        iconFg = PamodziColors.green;
        break;
      default:
        iconBg = PamodziColors.blueGl;
        iconFg = PamodziColors.blue;
    }

    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, a, __) => MaintenanceDetailScreen(issue: issue),
              transitionsBuilder: (_, a, __, child) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 220),
            ),
          );
        },
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
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(issueIcon(issue.iconType), color: iconFg, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(issue.title,
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: textColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('${issue.category} · Reported ${issue.date}',
                        style: TextStyle(fontSize: 10.5, color: mutedColor)),
                    Text('👷 ${issue.assignee}', style: TextStyle(fontSize: 10.5, color: mutedColor)),
                    const SizedBox(height: 5),
                    IssueStatusChip(status: issue.status),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: mutedColor, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── NEW MAINTENANCE FORM ──────────────────────────────────────────────────────
class NewMaintenanceScreen extends StatefulWidget {
  const NewMaintenanceScreen({super.key});

  @override
  State<NewMaintenanceScreen> createState() => _NewMaintenanceScreenState();
}

class _NewMaintenanceScreenState extends State<NewMaintenanceScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _imageService = ImageService();
  String _category = 'Plumbing';
  String? _priority;
  List<File> _selectedImages = [];

  final List<String> _categories = ['Plumbing', 'Electrical', 'Roof / Ceiling', 'Security / Locks', 'Appliances', 'General'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) {
      showToast('Please add an issue title');
      return;
    }

    String iconType = 'general';
    if (_category == 'Plumbing') iconType = 'plumbing';
    else if (_category == 'Electrical') iconType = 'electrical';
    else if (_category == 'Security / Locks') iconType = 'security';
    else if (_category == 'Appliances') iconType = 'appliances';

    // Convert file paths to strings for storage
    final photoUrls = _selectedImages.map((file) => file.path).toList();

    context.read<AppState>().addIssue(MaintenanceIssue(
      title: _titleCtrl.text.trim(),
      category: _category,
      status: 'open',
      priority: _priority ?? 'medium',
      date: 'Just now',
      assignee: 'Awaiting assignment',
      iconType: iconType,
      description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
      photoUrls: photoUrls.isNotEmpty ? photoUrls : null,
    ));

    showToast('Issue reported — landlord notified ✓');
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _pickImageFromCamera() async {
    final file = await _imageService.pickFromCamera();
    if (file != null) {
      setState(() {
        if (_selectedImages.length < 5) {
          _selectedImages.add(file);
        } else {
          showToast('Maximum 5 photos allowed');
        }
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final file = await _imageService.pickFromGallery();
    if (file != null) {
      setState(() {
        if (_selectedImages.length < 5) {
          _selectedImages.add(file);
        } else {
          showToast('Maximum 5 photos allowed');
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? PamodziColors.bgDark : PamodziColors.bg;
    final surfaceColor = isDark ? PamodziColors.surfaceDark : PamodziColors.surface;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final textColor = isDark ? PamodziColors.textDark : PamodziColors.text;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;
    final greenColor = isDark ? PamodziColors.greenDark2 : PamodziColors.green;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(title: 'Report an Issue'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FormLabel(label: 'Category'),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor, width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                          color: bgColor,
                        ),
                        child: DropdownButton<String>(
                          value: _category,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: surfaceColor,
                          style: TextStyle(color: textColor, fontSize: 14, fontFamily: 'Inter'),
                          items: _categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setState(() => _category = v!),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _FormLabel(label: 'Issue title'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _titleCtrl,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'e.g. Kitchen tap leaking at base',
                          hintStyle: TextStyle(color: mutedColor, fontSize: 13),
                          filled: true,
                          fillColor: bgColor,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _FormLabel(label: 'Description'),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 4,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Describe the problem in detail…',
                          hintStyle: TextStyle(color: mutedColor, fontSize: 13),
                          filled: true,
                          fillColor: bgColor,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _FormLabel(label: 'Priority'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _PriorityBtn(label: '🔴 Urgent', value: 'urgent', selected: _priority,
                              color: PamodziColors.red, onTap: () => setState(() => _priority = 'urgent')),
                          const SizedBox(width: 8),
                          _PriorityBtn(label: '🟡 High', value: 'high', selected: _priority,
                              color: PamodziColors.amber, onTap: () => setState(() => _priority = 'high')),
                          const SizedBox(width: 8),
                          _PriorityBtn(label: '🔵 Medium', value: 'medium', selected: _priority,
                              color: PamodziColors.blue, onTap: () => setState(() => _priority = 'medium')),
                          const SizedBox(width: 8),
                          _PriorityBtn(label: '🟢 Low', value: 'low', selected: _priority,
                              color: PamodziColors.green, onTap: () => setState(() => _priority = 'low')),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _FormLabel(label: 'Add photos (optional)'),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _PhotoBox(
                              icon: Icons.camera_alt_outlined,
                              onTap: _pickImageFromCamera,
                            ),
                            const SizedBox(width: 10),
                            _PhotoBox(
                              icon: Icons.image_outlined,
                              onTap: _pickImageFromGallery,
                            ),
                            const SizedBox(width: 10),
                            // Display selected images
                            ..._selectedImages.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: _SelectedImageBox(
                                  file: file,
                                  onRemove: () => _removeImage(index),
                                ),
                              );
                            }),
                            if (_selectedImages.length < 5)
                              _PhotoBox(
                                icon: Icons.add,
                                onTap: _pickImageFromGallery,
                              ),
                          ],
                        ),
                      ),
                      if (_selectedImages.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${_selectedImages.length}/5 photos added',
                            style: TextStyle(fontSize: 10, color: mutedColor),
                          ),
                        ),
                      const SizedBox(height: 20),

                      PamodziButton(
                        label: 'Submit Report',
                        icon: Icons.send_outlined,
                        onTap: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String label;
  const _FormLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;
    return Text(
      label.toUpperCase(),
      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: mutedColor, letterSpacing: 0.8),
    );
  }
}

class _PriorityBtn extends StatelessWidget {
  final String label, value;
  final String? selected;
  final Color color;
  final VoidCallback onTap;

  const _PriorityBtn({
    required this.label,
    required this.value,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = value == selected;
    final surface2 = isDark ? PamodziColors.surface2Dark : PamodziColors.surface2;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : surface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color.withOpacity(0.5) : borderColor),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: isSelected ? color : (isDark ? PamodziColors.text2Dark : PamodziColors.text2),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoBox extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PhotoBox({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface2 = isDark ? PamodziColors.surface2Dark : PamodziColors.surface2;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;
    final mutedColor = isDark ? PamodziColors.mutedDark : PamodziColors.muted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor),
        ),
        child: Icon(icon, color: mutedColor, size: 22),
      ),
    );
  }
}

class _SelectedImageBox extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _SelectedImageBox({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? PamodziColors.borderDark : PamodziColors.border;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: PamodziColors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


// ── MAINTENANCE DETAIL SCREEN ─────────────────────────────────────────────────
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

    Color iconBg, iconFg;
    switch (issue.status) {
      case 'progress':
        iconBg = PamodziColors.amberGl;
        iconFg = PamodziColors.amber;
        break;
      case 'resolved':
        iconBg = PamodziColors.greenGl;
        iconFg = PamodziColors.green;
        break;
      default:
        iconBg = PamodziColors.blueGl;
        iconFg = PamodziColors.blue;
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
                    // Issue header card
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
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(issueIcon(issue.iconType), color: iconFg, size: 24),
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
                                    IssueStatusChip(status: issue.status),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _DetailRow('Category', issue.category, textColor, text2Color, borderColor),
                          _DetailRow('Priority', issue.priority.toUpperCase(), textColor, text2Color, borderColor),
                          _DetailRow('Reported', issue.date, textColor, text2Color, borderColor),
                          _DetailRow('Assigned to', issue.assignee, textColor, text2Color, Colors.transparent),
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
                              spacing: 8,
                              runSpacing: 8,
                              children: issue.photoUrls!.map((path) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(path),
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
  final Color textColor, text2Color, borderColor;

  const _DetailRow(this.label, this.value, this.textColor, this.text2Color, this.borderColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: text2Color)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textColor)),
        ],
      ),
    );
  }
}
