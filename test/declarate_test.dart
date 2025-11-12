// ------------------------------------------------------------ //
//  declarate_test.dart
//
//  Unit & Widget tests for Declarate, Declarator, and Declarion.
//  Created by Siva Sankar on 2025-11-12.
// ------------------------------------------------------------ //

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/declarate.dart';

// ------------------------------------------------------------ //
//  Mock Declarates for Testing
// ------------------------------------------------------------ //

class CounterDeclarate extends Declarate {
  int count = 0;

  void increment() => react(() => count++);
  void decrement() => react(() => count--);
}

class AsyncDeclarate extends Declarate {
  bool loading = false;
  int data = 0;

  Future<void> loadData() => react(() async {
        loading = true;
        await Future.delayed(const Duration(milliseconds: 50));
        data = 42;
        loading = false;
      });
}

class HookedDeclarate extends Declarate {
  bool willCalled = false;
  bool didCalled = false;

  @override
  void willEmit() {
    willCalled = true;
  }

  @override
  void didEmit() {
    didCalled = true;
  }

  void trigger() => react(() {});
}

// ------------------------------------------------------------ //
//  Declarate (Logic) Tests
// ------------------------------------------------------------ //

void main() {
  group('Declarate — Reactive Logic', () {
    test('emit() notifies listeners', () {
      final declarate = CounterDeclarate();
      var called = false;

      declarate.addListener(() {
        called = true;
      });

      declarate.emit();
      expect(called, isTrue);
    });

    test('react() executes mutation and emits once', () {
      final declarate = CounterDeclarate();
      var calls = 0;

      declarate.addListener(() => calls++);
      declarate.increment();

      expect(declarate.count, 1);
      expect(calls, 1);
    });

    test('asyncReact() performs async update and notifies', () async {
      final declarate = AsyncDeclarate();
      var emitted = false;

      declarate.addListener(() => emitted = true);
      await declarate.loadData();

      expect(declarate.data, 42);
      expect(emitted, isTrue);
    });

    test('willEmit() and didEmit() are called during update', () {
      final declarate = HookedDeclarate();
      declarate.trigger();

      expect(declarate.willCalled, isTrue);
      expect(declarate.didCalled, isTrue);
    });

    test('multiple listeners are notified on emit()', () {
      final declarate = CounterDeclarate();
      var a = 0, b = 0;

      declarate
        ..addListener(() => a++)
        ..addListener(() => b++);

      declarate.emit();

      expect(a, 1);
      expect(b, 1);
    });

    test('asyncReact() handles thrown exceptions', () async {
      final declarate = CounterDeclarate();

      expect(
        declarate.react(() async => throw Exception('Async error')),
        throwsA(isA<Exception>()),
      );
    });

    test('dispose() safely removes listeners', () {
      final declarate = CounterDeclarate();
      declarate.dispose();

      expect(() => declarate.emit(), returnsNormally);
    });
  });

  // ------------------------------------------------------------ //
  //  Declarion (Provider) Tests
  // ------------------------------------------------------------ //

  group('Declarion — Multi Provider', () {
    testWidgets('provides multiple declarates', (tester) async {
      final counter = CounterDeclarate();
      final async = AsyncDeclarate();

      await tester.pumpWidget(
        Declarion(
          declarates: [counter, async],
          child: Builder(builder: (context) {
            final counterFromContext = Declarion.of<CounterDeclarate>(context);
            final asyncFromContext = Declarion.of<AsyncDeclarate>(context);
            expect(counterFromContext, equals(counter));
            expect(asyncFromContext, equals(async));
            return const SizedBox();
          }),
        ),
      );
    });

    testWidgets('throws assertion error if no provider found', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(
        () => Declarion.of<CounterDeclarate>(tester.element(find.byType(SizedBox))),
        throwsAssertionError,
      );
    });
  });

  // ------------------------------------------------------------ //
  //  Declarator (Widget Builder) Tests
  // ------------------------------------------------------------ //

  group('Declarator — Reactive Builder', () {
    testWidgets('rebuilds UI when declarate emits', (tester) async {
      final declarate = CounterDeclarate();

      await tester.pumpWidget(
        Declarion(
          declarates: [declarate],
          child: MaterialApp(
            home: Declarator<CounterDeclarate>(
              builder: (context, dc) => Text('Count: ${dc.count}', textDirection: TextDirection.ltr),
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      declarate.increment();
      await tester.pump();

      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('listener runs without rebuilding when triggered', (tester) async {
      final declarate = CounterDeclarate();
      var listenerCalled = false;

      await tester.pumpWidget(
        Declarion(
          declarates: [declarate],
          child: MaterialApp(
            home: Declarator<CounterDeclarate>(
              listener: (_, dc) => listenerCalled = true,
              builder: (context, dc) => Text('Count: ${dc.count}', textDirection: TextDirection.ltr),
            ),
          ),
        ),
      );

      declarate.increment();
      await tester.pump();

      expect(listenerCalled, isTrue);
    });

    testWidgets('buildWhen prevents rebuild when false', (tester) async {
      final declarate = CounterDeclarate();
      var buildCount = 0;

      await tester.pumpWidget(
        Declarion(
          declarates: [declarate],
          child: MaterialApp(
            home: Declarator<CounterDeclarate>(
              buildWhen: (prev, next) => false,
              builder: (context, dc) {
                  buildCount++;
                return Text('Count: ${dc.count}', textDirection: TextDirection.ltr);
              },
            ),
          ),
        ),
      );

      expect(buildCount, 1);

      declarate.increment();
      await tester.pump();

      expect(buildCount, 1); // Should not rebuild
    });

    testWidgets('Declarator updates after asyncReact', (tester) async {
      final declarate = AsyncDeclarate();

      await tester.pumpWidget(
        Declarion(
          declarates: [declarate],
          child: MaterialApp(
            home: Declarator<AsyncDeclarate>(
              builder: (context, dc) => Text(
                dc.loading ? 'Loading...' : 'Data: ${dc.data}',
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Data: 0'), findsOneWidget);

      declarate.loadData();
      await tester.pump(); // loading true
      await tester.pump(const Duration(milliseconds: 100)); // after delay

      expect(find.text('Data: 42'), findsOneWidget);
    });
  });
}
