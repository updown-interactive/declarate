import 'declarate.dart';
import 'package:flutter/material.dart';



/// Provides multiple [DeclarateViewModel]s to the widget tree.
/// 
/// Similar to MultiBlocProvider, but lighter and Declar-style declarative.
class Declarion extends InheritedWidget {
  final Map<Type, Declarate> _declarates;

  const Declarion._internal({
    super.key,
    required Map<Type, Declarate> declarates,
    required super.child,
  }) : _declarates = declarates;

  /// Creates a [Declarion] with one or more [DeclarateViewModel]s.
  factory Declarion({
    Key? key,
    required List<Declarate> declarates,
    required Widget child,
  }) {
    final map = {for (final vm in declarates) vm.runtimeType: vm};
    return Declarion._internal(key: key, declarates: map, child: child);
  }

  /// Retrieves a provided [Declarate] of type [T].
  static T of<T extends Declarate>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<Declarion>();
    assert(provider != null, 'No Declarion found in context');
    final viewModel = provider!._declarates[T];
    assert(viewModel != null,
        'No ViewModel of type $T found in Declarion');
    return viewModel as T;
  }

  @override
  bool updateShouldNotify(covariant Declarion oldWidget) {
    if (_declarates.length != oldWidget._declarates.length) return true;
    for (final key in _declarates.keys) {
      if (_declarates[key] != oldWidget._declarates[key]) return true;
    }
    return false;
  }
}
