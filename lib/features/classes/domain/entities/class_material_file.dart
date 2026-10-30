import 'package:equatable/equatable.dart';

class ClassMaterialFile extends Equatable {
  const new({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
  });

  final String id;
  final String name;
  final String url;

  // Backend `classMaterialType`: 0 is an external link, anything else an
  // uploaded file whose kind (pdf, docx, ...) is read from its URL.
  final int type;

  bool get isLink => type == 0;

  @override
  List<Object?> get props => [id, name, url, type];
}
