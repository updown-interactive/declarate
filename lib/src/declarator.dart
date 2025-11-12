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
  /// The function that builds the widget tree using the [Declarate].
  final Widget Function(BuildContext context, T dc) builder;

  /// Optional callback for reacting to updates without rebuilding the UI.
  final void Function(BuildContext context, T dc)? listener;

  /// Optional filter: decides whether to rebuild after a change.
  /// If omitted, rebuilds on every [emit] or [react] call.
  ///
  /// The function receives the [declarate] before and after the update.
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
  late final T declarate;
  late T _previousSnapshot;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    declarate = Declarion.of<T>(context);
    _previousSnapshot = declarate;
    declarate.addListener(_onDeclarateChanged);
  }

  void _onDeclarateChanged() {
    // Trigger listener first
    widget.listener?.call(context, declarate);

    // Rebuild if buildWhen allows or if no condition is provided
    final shouldRebuild = widget.buildWhen?.call(_previousSnapshot, declarate) ?? true;
    if (shouldRebuild && mounted) {
      setState(() {});
    }

    _previousSnapshot = declarate;
  }

  @override
  void dispose() {
    declarate.removeListener(_onDeclarateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, declarate);
}
