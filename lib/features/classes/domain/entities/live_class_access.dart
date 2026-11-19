import 'package:equatable/equatable.dart';

// What the app needs to enter a live class room: the LiveKit server and
// the per-session access token returned by ClassRoom/join.
class LiveClassAccess extends Equatable {
  const new({required this.serverUrl, required this.token});

  final String serverUrl;
  final String token;

  @override
  List<Object?> get props => [serverUrl, token];
}
