typedef GetterCallback<T extends Object?> = T Function();
typedef SetterCallback<S extends Object?> = void Function(S value);
typedef FieldsGetter = Map<String, ExactFieldAccess> Function();
typedef DefaultValueCallback<T> = T? Function();
typedef FieldOptionsGetter<T> = Iterable<T> Function();

mixin BagOfFieldsMixin {
  Map<String, FieldAccess> get fields;
}

final class ExactFieldAccess<T extends Object?> extends FieldAccess<T, T> {
  const ExactFieldAccess(
    SetterCallback<T> setter,
    GetterCallback<T> getter, {
    DefaultValueCallback<T>? defaultValue,
  }) : super(setter, getter, defaultValue: defaultValue);

  const ExactFieldAccess.options(
    SetterCallback<T> setter,
    GetterCallback<T> getter, {
    required FieldOptionsGetter<T> options,
    DefaultValueCallback<T>? defaultValue,
  }) : super.options(setter, getter,
            options: options, defaultValue: defaultValue);
}

class FieldAccess<T extends Object?, S extends Object?> {
  final SetterCallback<S> _setter;
  final GetterCallback<T> _getter;

  SetterCallback<S> get setValue => _setter;

  GetterCallback<T> get getValue => _getter;

  GetterCallback<List<BagOfFieldsMixin>> get getList =>
      getValue as GetterCallback<List<BagOfFieldsMixin>>;

  bool get hasNested => getValue() is List<BagOfFieldsMixin>;

  final FieldOptionsGetter<T>? _options;

  FieldOptionsGetter<T>? get getOptions => _options;

  bool get hasOptions => _options != null;

  final DefaultValueCallback<T>? _defaultValue;

  DefaultValueCallback<T>? get getDefaultValue => _defaultValue;

  const FieldAccess(
    SetterCallback<S> setter,
    GetterCallback<T> getter, {
    DefaultValueCallback<T>? defaultValue,
  })  : _setter = setter,
        _getter = getter,
        _defaultValue = defaultValue,
        _options = null;

  const FieldAccess.options(
    SetterCallback<S> setter,
    GetterCallback<T> getter, {
    required FieldOptionsGetter<T> options,
    DefaultValueCallback<T>? defaultValue,
  })  : _setter = setter,
        _getter = getter,
        _options = options,
        _defaultValue = defaultValue;
}
