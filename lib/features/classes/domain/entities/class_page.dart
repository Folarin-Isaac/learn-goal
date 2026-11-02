import 'package:equatable/equatable.dart';
import 'package:lengoal/features/classes/domain/entities/lengoal_class.dart';

class ClassPage extends Equatable {
  const new({required this.items, required this.hasMore});

  final List<LengoalClass> items;
  final bool hasMore;

  @override
  List<Object?> get props => [items, hasMore];
}
