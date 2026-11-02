import 'package:equatable/equatable.dart';

/// مواصفات ملف طباعة واحد. كل ملف له مواصفاته المستقلة.
class PrintSpec extends Equatable {
  const PrintSpec({
    required this.paperSize,
    required this.color,
    required this.sides,
    required this.binding,
    this.copies = 1,
    this.pageRange = '',
    this.notes = '',
  });

  final String paperSize;

  /// قيمة print_color من modules_config.printing.print_colors.
  final String color;

  /// قيمة print_sides من modules_config.printing.print_sides.
  final String sides;

  /// مفتاح من modules_config.printing.bindings.
  final String binding;
  final int copies;

  /// فارغ = كل الصفحات (الخادم يرفض الكلمة "All").
  final String pageRange;
  final String notes;

  PrintSpec copyWith({
    String? paperSize,
    String? color,
    String? sides,
    String? binding,
    int? copies,
    String? pageRange,
    String? notes,
  }) =>
      PrintSpec(
        paperSize: paperSize ?? this.paperSize,
        color: color ?? this.color,
        sides: sides ?? this.sides,
        binding: binding ?? this.binding,
        copies: copies ?? this.copies,
        pageRange: pageRange ?? this.pageRange,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() => {
        'paper_size': paperSize,
        'print_color': color,
        'print_sides': sides,
        'binding_type': binding,
        'print_copies': copies,
        'page_range': pageRange,
        'notes': notes,
      };

  factory PrintSpec.fromJson(Map<String, dynamic> json) => PrintSpec(
        paperSize: json['paper_size'] as String,
        color: json['print_color'] as String,
        sides: json['print_sides'] as String,
        binding: json['binding_type'] as String,
        copies: json['print_copies'] as int? ?? 1,
        pageRange: json['page_range'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
      );

  @override
  List<Object?> get props =>
      [paperSize, color, sides, binding, copies, pageRange, notes];
}
