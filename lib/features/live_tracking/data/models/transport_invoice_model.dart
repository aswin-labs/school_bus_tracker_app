class TransportInvoiceResponse {
  final int totalContent;
  final int totalPages;
  final int currentPage;
  final List<TransportInvoiceModel> data;

  TransportInvoiceResponse({
    this.totalContent = 0,
    this.totalPages = 0,
    this.currentPage = 0,
    this.data = const [],
  });

  factory TransportInvoiceResponse.fromJson(Map<String, dynamic> json) {
    final list = json['data'];
    return TransportInvoiceResponse(
      totalContent: json['totalcontent'] is int
          ? json['totalcontent']
          : int.tryParse(json['totalcontent']?.toString() ?? '0') ?? 0,
      totalPages: json['totalPages'] is int
          ? json['totalPages']
          : int.tryParse(json['totalPages']?.toString() ?? '0') ?? 0,
      currentPage: json['currentPage'] is int
          ? json['currentPage']
          : int.tryParse(json['currentPage']?.toString() ?? '0') ?? 0,
      data: list is List
          ? list.map((e) => TransportInvoiceModel.fromJson(e)).toList()
          : [],
    );
  }
}

class InvoiceStopModel {
  final int? id;
  final String? stopName;

  InvoiceStopModel({this.id, this.stopName});

  factory InvoiceStopModel.fromJson(Map<String, dynamic> json) {
    return InvoiceStopModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      stopName: json['stop_name']?.toString(),
    );
  }
}

class TransportInvoiceModel {
  final int id;
  final int? schoolId;
  final int? stopId;
  final int? studentId;
  final String amount;
  final String? term;
  final String? dueDate;
  final String status;
  final bool trash;
  final String? createdAt;
  final String? updatedAt;
  final InvoiceStopModel? stop;

  TransportInvoiceModel({
    required this.id,
    this.schoolId,
    this.stopId,
    this.studentId,
    required this.amount,
    this.term,
    this.dueDate,
    required this.status,
    this.trash = false,
    this.createdAt,
    this.updatedAt,
    this.stop,
  });

  double get amountValue => double.tryParse(amount) ?? 0.0;

  bool get isPaid => status.toLowerCase() == 'paid';

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isWaitingApproval =>
      status.toLowerCase() == 'waiting_for_approval' ||
      status.toLowerCase() == 'waiting for approval';

  bool get isPartiallyPaid =>
      status.toLowerCase() == 'partially_paid' ||
      status.toLowerCase() == 'partially paid';

  bool get isOutstanding => !isPaid;

  bool get isOverdue {
    if (isPaid || dueDate == null || dueDate!.isEmpty) return false;
    try {
      final due = DateTime.parse(dueDate!);
      final now = DateTime.now();
      return now.isAfter(DateTime(due.year, due.month, due.day, 23, 59, 59));
    } catch (_) {
      return false;
    }
  }

  factory TransportInvoiceModel.fromJson(Map<String, dynamic> json) {
    return TransportInvoiceModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      schoolId: json['school_id'] is int
          ? json['school_id']
          : int.tryParse(json['school_id']?.toString() ?? ''),
      stopId: json['stop_id'] is int
          ? json['stop_id']
          : int.tryParse(json['stop_id']?.toString() ?? ''),
      studentId: json['student_id'] is int
          ? json['student_id']
          : int.tryParse(json['student_id']?.toString() ?? ''),
      amount: json['amount']?.toString() ?? '0.00',
      term: json['term']?.toString(),
      dueDate: json['due_date']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      trash: json['trash'] == true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      stop: json['Stop'] is Map<String, dynamic>
          ? InvoiceStopModel.fromJson(json['Stop'])
          : null,
    );
  }
}
