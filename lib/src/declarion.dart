import 'declarate.dart';
import 'package:flutter/material.dart';



/// Provides multiple [DeclarateViewModel]s to the widget tree.
/// 
/// Similar to MultiBlocProvider, but lighter and Declar-style declarative.
class Declarion extends InheritedWidget {
  final Map<Type, Declarate> _declarates;
  final Map<Type, int> _versions;

  const Declarion._internal({
    super.key,
    required Map<Type, Declarate> declarates,
    required Map<Type, int> versions,
    required super.child,
  }) : _declarates = declarates,
       _versions = versions;

  factory Declarion({
    Key? key,
    required List<Declarate> declarates,
    required Widget child,
  }) {
    final map = <Type, Declarate>{};
    final versions = <Type, int>{};
    
    for (final dc in declarates) {
      final type = dc.runtimeType;
      assert(!map.containsKey(type), 
        'Duplicate Declarate type: $type. Each type can only be provided once.');
      map[type] = dc;
      versions[type] = dc.version;
    }
    
    return Declarion._internal(
      key: key, 
      declarates: map, 
      versions: versions,
      child: child
    );
  }

  static T of<T extends Declarate>(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<Declarion>();
    assert(provider != null, 'No Declarion found in context');
    
    final declarate = provider!._declarates[T];
    assert(declarate != null, 'No Declarate of type $T found in Declarion');
    
    return declarate as T;
  }

  @override
  bool updateShouldNotify(covariant Declarion oldWidget) {
    // Check if any Declarate version has changed
    for (final type in _versions.keys) {
      final oldVersion = oldWidget._versions[type] ?? -1;
      final newVersion = _versions[type] ?? -1;
      if (oldVersion != newVersion) return true;
    }
    return false;
  }
}
