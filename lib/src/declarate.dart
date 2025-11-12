// ------------------------------------------------------------ //
//  declarate.dart
//
//  Created by Siva Sankar on 2025-11-12.
//  Updated: unified react() for sync and async support
// ------------------------------------------------------------ //

import 'dart:async';
import 'package:flutter/material.dart';

/// Base class for Declarate — a stateless, reactive logic holder.
///
/// Declarate enables simple, SwiftUI-style reactive logic:
/// freely mutate fields, and call [react] or [emit] to notify the UI.
///
/// Example:
/// ```dart
/// class CounterDeclarate extends Declarate {
///   int count = 0;
///
///   void increment() => react(() => count++);
///
///   void load() => react(() async {
///     await Future.delayed(Duration(seconds: 1));
///     count++;
///   });
/// }
/// ```
abstract class Declarate extends ChangeNotifier {
  bool _disposed = false;

  /// Notifies all listeners to rebuild (like setState),
  /// automatically triggering lifecycle hooks.
  @protected
  void emit() {
    if (_disposed) return;

    willEmit();
    notifyListeners();
    didEmit();
  }

  /// Unified `react()` — automatically supports both sync and async blocks.
  ///
  /// Example:
  /// ```dart
  /// react(() => count++);                       // sync
  /// react(() async { await Future.delayed(...); count++; });  // async
  /// ```
  @protected
  Future<void> react(FutureOr<void> Function() block) async {
    if (_disposed) return;

    final result = block();

    // If it's synchronous
    if (result is! Future) {
      if (_disposed) return;
      emit();
      return;
    }

    // If it's asynchronous
    await result;
    if (_disposed) return;
    emit();
  }

  /// Lifecycle hook — called before notifying listeners.
  @protected
  void willEmit() {}

  /// Lifecycle hook — called after notifying listeners.
  @protected
  void didEmit() {}

  /// Override dispose to mark this Declarate as disposed and call super.
  @override
  @mustCallSuper
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// For testing or advanced use: whether this Declarate has been disposed.
  @protected
  bool get isDisposed => _disposed;
}
