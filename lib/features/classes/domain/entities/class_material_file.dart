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

  // Raw backend `classMaterialType` code; its meaning isn't documented
  // yet, so the UI infers the file kind from the name/URL instead.
  final int type;

  @override
  List<Object?> get props => [id, name, url, type];
}
