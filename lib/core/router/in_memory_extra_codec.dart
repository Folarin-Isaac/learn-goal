import 'dart:collection';
import 'dart:convert';

// go_router serialises `extra` whenever it re-parses route information
// (every refreshListenable tick, e.g. an auth-status emission). Without a
// codec, any extra that isn't plain JSON (LengoalClass, ClassMaterial…)
// comes back null and `state.extra!` crashes the page. This codec swaps
// each extra for an id and keeps the real object in memory, so a re-parse
// hands back the same instance. It doesn't survive process death, which
// the app doesn't restore anyway.
class InMemoryExtraCodec extends Codec<Object?, Object?> {
  const new();

  @override
  Converter<Object?, Object?> get encoder => const _Encoder();

  @override
  Converter<Object?, Object?> get decoder => const _Decoder();
}

class _ExtraStore {
  static const int _capacity = 200;
  static final LinkedHashMap<int, Object> _byId = LinkedHashMap();
  static int _nextId = 0;

  static int put(Object value) {
    for (final entry in _byId.entries) {
      if (identical(entry.value, value)) return entry.key;
    }
    final id = _nextId++;
    _byId[id] = value;
    if (_byId.length > _capacity) _byId.remove(_byId.keys.first);
    return id;
  }

  static Object? get(int id) => _byId[id];
}

const String _idKey = 'inMemoryExtraId';

class _Encoder extends Converter<Object?, Object?> {
  const new();

  @override
  Object? convert(Object? input) {
    if (input == null) return null;
    return <String, Object?>{_idKey: _ExtraStore.put(input)};
  }
}

class _Decoder extends Converter<Object?, Object?> {
  const new();

  @override
  Object? convert(Object? input) {
    if (input is! Map) return null;
    final id = input[_idKey];
    return id is int ? _ExtraStore.get(id) : null;
  }
}
