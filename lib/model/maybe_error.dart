/// Contains a successful value OR an error.
class MaybeError<T> {
  const MaybeError.value(T this._value) : _error = null;
  const MaybeError.error(String this._error) : _value = null;

  final T? _value;
  final String? _error;

  bool get isError => _value == null;
  bool get isValue => _error == null;

  T get value => _value!;
  String get error => _error!;
}
