// Payment model
class Payment {
  final String month;
  final double amount;
  final String method;
  final String ref;
  final String date;
  final String status;

  const Payment({
    required this.month,
    required this.amount,
    required this.method,
    required this.ref,
    required this.date,
    required this.status,
  });
}

// Maintenance issue model
class MaintenanceIssue {
  final String title;
  final String category;
  final String status; // open, progress, resolved
  final String priority; // low, medium, high, urgent
  final String date;
  final String assignee;
  final String iconType; // plumbing, electrical, security, general
  final String? description;
  final List<String>? photoUrls;

  const MaintenanceIssue({
    required this.title,
    required this.category,
    required this.status,
    required this.priority,
    required this.date,
    required this.assignee,
    required this.iconType,
    this.description,
    this.photoUrls,
  });

  MaintenanceIssue copyWith({
    String? title,
    String? category,
    String? status,
    String? priority,
    String? date,
    String? assignee,
    String? iconType,
    String? description,
    List<String>? photoUrls,
  }) {
    return MaintenanceIssue(
      title: title ?? this.title,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      assignee: assignee ?? this.assignee,
      iconType: iconType ?? this.iconType,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }
}

// Notification model
class AppNotification {
  final String type; // green, amber, red, blue
  final String iconType;
  final String title;
  final String body;
  final String time;
  bool unread;

  AppNotification({
    required this.type,
    required this.iconType,
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
  });
}

// Tenant model
class Tenant {
  final String name;
  final String email;
  final String phone;
  final String unit;
  final String estate;
  final String city;
  final String initials;

  const Tenant({
    required this.name,
    required this.email,
    required this.phone,
    required this.unit,
    required this.estate,
    required this.city,
    required this.initials,
  });
}

// Lease model
class Lease {
  final String tenantName;
  final String property;
  final String landlord;
  final String landlordEmail;
  final String startDate;
  final String endDate;
  final double monthlyRent;
  final String dueDate;
  final double lateFee;
  final int lateDays;
  final double deposit;

  const Lease({
    required this.tenantName,
    required this.property,
    required this.landlord,
    required this.landlordEmail,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    required this.dueDate,
    required this.lateFee,
    required this.lateDays,
    required this.deposit,
  });
}
