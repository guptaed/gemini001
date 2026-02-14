import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'approved':
      case 'passed':
      case 'paid':
      case 'delivered':
      case 'received':
      case 'open':
      case 'active':
        return const Color(0xFFE8F5E9);
      case 'pending':
      case 'submitted':
      case 'in progress':
      case 'shipped':
        return const Color(0xFFFFF8E1);
      case 'rejected':
      case 'failed':
      case 'closed':
      case 'overdue':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color get _textColor {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'approved':
      case 'passed':
      case 'paid':
      case 'delivered':
      case 'received':
      case 'open':
      case 'active':
        return const Color(0xFF2E7D32);
      case 'pending':
      case 'submitted':
      case 'in progress':
      case 'shipped':
        return const Color(0xFFF57F17);
      case 'rejected':
      case 'failed':
      case 'closed':
      case 'overdue':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF616161);
    }
  }
}
