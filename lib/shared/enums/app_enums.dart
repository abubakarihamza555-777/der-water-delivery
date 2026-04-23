enum UserRole {
  customer,
  delivery,
  admin,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.delivery:
        return 'delivery';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'delivery':
        return UserRole.delivery;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.delivery:
        return 'Delivery Partner';
      case UserRole.admin:
        return 'Administrator';
    }
  }
}

enum OrderType {
  bottle,
  tank,
}

enum DeliveryStatus {
  pending,
  accepted,
  picked,
  enRoute,
  delivered,
  cancelled,
}

extension DeliveryStatusExtension on DeliveryStatus {
  String get value {
    switch (this) {
      case DeliveryStatus.pending:
        return 'pending';
      case DeliveryStatus.accepted:
        return 'accepted';
      case DeliveryStatus.picked:
        return 'picked';
      case DeliveryStatus.enRoute:
        return 'en_route';
      case DeliveryStatus.delivered:
        return 'delivered';
      case DeliveryStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayName {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.accepted:
        return 'Accepted';
      case DeliveryStatus.picked:
        return 'Picked Up';
      case DeliveryStatus.enRoute:
        return 'En Route';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum NotificationType {
  order,
  promo,
  update,
  system,
}

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.order:
        return 'order';
      case NotificationType.promo:
        return 'promo';
      case NotificationType.update:
        return 'update';
      case NotificationType.system:
        return 'system';
    }
  }

  String get displayName {
    switch (this) {
      case NotificationType.order:
        return 'Order Update';
      case NotificationType.promo:
        return 'Promotion';
      case NotificationType.update:
        return 'App Update';
      case NotificationType.system:
        return 'System Message';
    }
  }
}