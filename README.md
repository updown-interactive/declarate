

# Declarate

**Declarate** is a lightweight, stateless, and declarative reactive logic framework for Flutter and Dart.
It simplifies application logic management by providing a clean, SwiftUI-inspired model for building reactive UI layers without boilerplate `State` or `Bloc` classes.

Declarate introduces a minimal and composable architecture with three key primitives:

* **Declarate** — a reactive logic holder (similar to Cubit or ViewModel)
* **Declarion** — a multi-provider for injecting view models
* **Declarator** — a reactive builder and listener widget

This design allows building UIs that react directly to logical changes, without manual wiring, boilerplate, or explicit `setState()` calls.

---

## Features

* Stateless, logic-driven design — no `State` classes required
* Unified `react()` method for both sync and async logic
* Lifecycle hooks (`willEmit` / `didEmit`)
* Safe disposal and listener management
* Multi-viewmodel support via `Declarion`
* Reactive builder and listener with `Declarator`
* Inspired by SwiftUI and Bloc, optimized for Flutter

---

## Installation

Add Declarate to your Flutter project:

```bash
dart pub add declarate
```

Then import it:

```dart
import 'package:declarate/declarate.dart';
```

---

## Example

### Counter Example

```dart
import 'package:declarate/declarate.dart';
import 'package:flutter/material.dart';

class CounterDeclarate extends Declarate {
  int count = 0;

  void increment() => react(() => count++);
  void decrement() => react(() => count--);
}

void main() {
  runApp(
    Declarion(
      declarates: [CounterDeclarate()],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Declarator<CounterDeclarate>(
        builder: (context, dc) => Scaffold(
          appBar: AppBar(title: const Text('Declarate Counter')),
          body: Center(child: Text('Count: ${dc.count}')),
          floatingActionButton: FloatingActionButton(
            onPressed: dc.increment,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
```

---

## Core Concepts

### 1. Declarate

`Declarate` is the core reactive class. It acts as a **logic holder** that emits rebuilds to the UI whenever its data changes.

```dart
class UserDeclarate extends Declarate {
  String name = "Guest";

  void changeName(String newName) => react(() => name = newName);
}
```

**Key features:**

* No state object — you freely define variables.
* Call `react()` after synchronous or asynchronous mutations.
* `emit()` can be called directly for manual rebuilds.

---

### 2. Declarion

`Declarion` is a multi-provider that makes one or more `Declarate` instances available down the widget tree.

```dart
Declarion(
  declarates: [
    CounterDeclarate(),
    UserDeclarate(),
  ],
  child: MyApp(),
);
```

Retrieve a view model anywhere in the widget tree:

```dart
final counter = Declarion.of<CounterDeclarate>(context);
```

---

### 3. Declarator

`Declarator` rebuilds your widget tree in response to updates from a specific `Declarate`.

```dart
Declarator<CounterDeclarate>(
  builder: (context, dc) => Text('Count: ${dc.count}'),
);
```

You can also attach listeners for one-time reactions:

```dart
Declarator<CounterDeclarate>(
  listener: (context, dc) {
    if (dc.count == 10) print('Reached 10!');
  },
  builder: (context, dc) => Text('Count: ${dc.count}'),
);
```

And conditionally rebuild using `buildWhen`:

```dart
Declarator<CounterDeclarate>(
  buildWhen: (prev, next) => prev.count != next.count,
  builder: (context, dc) => Text('Count: ${dc.count}'),
);
```

---

## Lifecycle Hooks

`Declarate` includes optional lifecycle methods for fine control around reactivity:

```dart
@override
void willEmit() {
  // Called before listeners are notified
}

@override
void didEmit() {
  // Called after listeners are notified
}
```

---

## Safe Disposal

Declarate automatically guards against calling `emit()` or `react()` after being disposed, ensuring safe teardown:

```dart
final dc = CounterDeclarate();
dc.dispose();
dc.emit(); // No error, safely ignored
```

---

## Unified React

`react()` intelligently detects whether the block is synchronous or asynchronous:

```dart
// Synchronous update
react(() => count++);

// Asynchronous update
react(() async {
  await Future.delayed(const Duration(seconds: 1));
  count++;
});
```

---

## Folder Structure

```
lib/
 ├── declarate.dart       # Core reactive base
 ├── declarion.dart       # Multi-provider for view models
 └── declarator.dart      # Builder and listener for Declarate
```

---

## Unit Testing

Declarate is designed for testability. You can verify reactivity easily:

```dart
test('react() triggers rebuilds', () {
  final dc = CounterDeclarate();
  var called = false;
  dc.addListener(() => called = true);

  dc.increment();
  expect(called, isTrue);
});
```

---

## License

This project is licensed under the **MIT License**.
See the [LICENSE](LICENSE) file for details.

---

## Author

Developed by **Siva Sankar**,
**Updown Interactive** — building declarative and elegant tools for Flutter development.
GitHub: [https://github.com/updown-interactive](https://github.com/updown-interactive)

---
