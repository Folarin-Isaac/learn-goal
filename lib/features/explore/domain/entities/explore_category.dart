import 'package:equatable/equatable.dart';

class ExploreCategory extends Equatable {
  const new({
    required this.id,
    required this.name,
    this.iconUrl,
    this.activeClassCount = 0,
  });

  final String id;
  final String name;
  final String? iconUrl;
  final int activeClassCount;

  @override
  List<Object?> get props => [id, name, iconUrl, activeClassCount];
}
