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

class FieldAccess<GetValue extends Object?, SetValue extends Object?> {
  final SetterCallback<SetValue> _setter;
  final GetterCallback<GetValue> _getter;

  SetterCallback<SetValue> get setValue => _setter;

  GetterCallback<GetValue> get getValue => _getter;

  final FieldOptionsGetter<GetValue>? _options;

  FieldOptionsGetter<GetValue>? get getOptions => _options;

  bool get hasOptions => _options != null;

  final DefaultValueCallback<GetValue>? _defaultValue;

  DefaultValueCallback<GetValue>? get getDefaultValue => _defaultValue;

  const FieldAccess(
    SetterCallback<SetValue> setter,
    GetterCallback<GetValue> getter, {
    DefaultValueCallback<GetValue>? defaultValue,
  })  : _setter = setter,
        _getter = getter,
        _defaultValue = defaultValue,
        _options = null;

  const FieldAccess.options(
    SetterCallback<SetValue> setter,
    GetterCallback<GetValue> getter, {
    required FieldOptionsGetter<GetValue> options,
    DefaultValueCallback<GetValue>? defaultValue,
  })  : _setter = setter,
        _getter = getter,
        _options = options,
        _defaultValue = defaultValue;
}
