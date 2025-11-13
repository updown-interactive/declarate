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
/// Base class for Declarate — a stateless, reactive logic holder.
abstract class Declarate extends ChangeNotifier {
  bool _disposed = false;
  int _version = 0;

  /// Current version number - increments on each emit
  int get version => _version;

  /// Notifies all listeners to rebuild
  @protected
  void emit() {
    if (_disposed) return;
    _version++;
    notifyListeners();
  }

  /// Unified react() — supports both sync and async blocks
  @protected
  Future<void> react(FutureOr<void> Function() block) async {
    if (_disposed) return;
    
    final result = block();
    
    if (result is! Future) {
      if (!_disposed) emit();
      return;
    }
    
    await result;
    if (!_disposed) emit();
  }

  @override
  @mustCallSuper
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @protected
  bool get isDisposed => _disposed;
}
