DateTime parseUtc(String iso) {
  return DateTime.parse(iso).toLocal();
}

String formatDate(String iso) {
  final dt = parseUtc(iso);
  return "${dt.day.toString().padLeft(2, '0')}-"
      "${dt.month.toString().padLeft(2, '0')}-"
      "${dt.year}";
}

String formatTime(String iso) {
  final dt = parseUtc(iso);
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final amPm = dt.hour >= 12 ? 'PM' : 'AM';
  return "$hour:$minute $amPm";
}

// Get day greeting
String getDayGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

// Get current date
String getCurrentDate() {
  final now = DateTime.now();
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
}
