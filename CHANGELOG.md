
---

## 1.0.0

### Initial Stable Release — Declarate

The first public release of **Declarate**, a lightweight, stateless, and declarative state management library for Flutter.
Declarate introduces a minimal, SwiftUI-inspired approach to managing application logic — without relying on `State`, `Cubit`, or `Bloc`.

---

### Highlights

* Introduced **Declarate**, the base reactive class for managing logic.

  * Supports both synchronous and asynchronous mutations via a unified `react()` method.
  * Includes lifecycle hooks: `willEmit()` and `didEmit()`.
  * Provides safe disposal and guards against post-dispose updates.

* Added **Declarion**, a multi-provider for injecting and managing multiple `Declarate` instances.

  * Simplified dependency access with `Declarion.of<T>(context)`.

* Added **Declarator**, a declarative builder and listener for reactive UI updates.

  * Supports `builder`, `listener`, and `buildWhen` for fine-grained rebuild control.
  * Combines the power of `BlocBuilder` and `BlocListener` into one minimal widget.

* Unified reactive syntax with a single `react()` method:

  * Works with both synchronous and asynchronous updates automatically.
  * Simplifies common patterns like counter updates or data fetches.

---

### Example

```dart
class CounterDeclarate extends Declarate {
  int count = 0;

  void increment() => react(() => count++);
  void loadAsync() => react(() async {
    await Future.delayed(const Duration(seconds: 1));
    count++;
  });
}

Declarion(
  viewModels: [CounterDeclarate()],
  child: Declarator<CounterDeclarate>(
    builder: (context, vm) => Text('Count: ${vm.count}'),
  ),
);
```

---

### Technical Improvements

* Implemented safe disposal tracking using `_disposed` flag.
* Added lifecycle safety for `emit()` and `react()`.
* Prevented rebuilds after disposal.
* Designed for composability with Declar UI framework and similar declarative architectures.

---

### Philosophy

Declarate is built on three core principles:

1. **Simplicity over boilerplate** — No `State` classes, no verbose patterns.
2. **Declarative reactivity** — UIs rebuild automatically on logic change.
3. **SwiftUI-like design** — Minimal syntax with clear lifecycle control.

---

### Repository

GitHub: [https://github.com/updown-interactive/declarate](https://github.com/updown-interactive/declarate)

---
