// ------------------------------------------------------------ //
//  declarator.dart
//
//  Created by Siva Sankar on 2025-11-12.
// ------------------------------------------------------------ //

import 'declarate.dart';
import 'declarion.dart';
import 'package:flutter/material.dart';

/// A declarative reactive builder that listens to a [Declarate].
///
/// It rebuilds the [builder] whenever the [Declarate] notifies listeners,
/// and can also run [listener] side effects after an update.
///
/// This replaces the need for both BlocBuilder and BlocListener,
/// offering a simpler, declarative API.
///
/// Example:
/// ```dart
/// Declarator<CounterDeclarate>(
///   listener: (context, vm) {
///     if (vm.count == 10) print('Reached 10!');
///   },
///   builder: (context, vm) => Text('Count: ${vm.count}'),
/// );
/// ```
class Declarator<T extends Declarate> extends StatefulWidget {
  final Widget Function(BuildContext context, T dc) builder;
  final void Function(BuildContext context, T dc)? listener;
  final bool Function(T prev, T next)? buildWhen;

  const Declarator({
    super.key,
    required this.builder,
    this.listener,
    this.buildWhen,
  });

  @override
  State<Declarator<T>> createState() => _DeclaratorState<T>();
}

class _DeclaratorState<T extends Declarate> extends State<Declarator<T>> {
  late T _declarate;
  int? _previousVersion;
  bool _listenerAttached = false;

  @override
  void initState() {
    super.initState();
    // Don't access context here - wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newDeclarate = Declarion.of<T>(context);

    // Only attach listener once or when declarate instance changes
    if (!_listenerAttached || _declarate != newDeclarate) {
      if (_listenerAttached) {
        _declarate.removeListener(_onDeclarateChanged);
      }

      _declarate = newDeclarate;
      _previousVersion = _declarate.version;
      _declarate.addListener(_onDeclarateChanged);
      _listenerAttached = true;
    }
  }

  void _onDeclarateChanged() {
    if (!mounted) return;

    // Call listener callback
    widget.listener?.call(context, _declarate);

    // Check if we should rebuild
    final shouldRebuild =
        widget.buildWhen?.call(_declarate, _declarate) ?? true;

    if (shouldRebuild) {
      setState(() {
        _previousVersion = _declarate.version;
      });
    }
  }

  @override
  void dispose() {
    if (_listenerAttached) {
      _declarate.removeListener(_onDeclarateChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _declarate);
}
