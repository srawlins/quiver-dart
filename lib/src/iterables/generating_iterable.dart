// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:collection';

Iterable generate(Function() initial, Function(dynamic) next) =>
    GeneratingIterable(initial, next);

/// An Iterable whose first value is the result of [_initial] and whose
/// subsequent values are generated by passing the current value to the [_next]
/// function.
///
/// The class is useful for creating lazy iterables from object hierarchies and
/// graphs.
///
/// The initial value and [_next] function are required to generate a sequence
/// that eventually terminates, otherwise calling methods that expect a finite
/// sequence, like `length` or `last`, will cause an infinite loop.
///
/// Example:
///
///     class Node {
///       Node parent;
///
///       /// An iterable of node and all ancestors up to the root.
///       Iterable<Node> ancestors =
///           GeneratingIterable<Node>(() => this, (n) => n.parent);
///
///       /// An iterable of the root and the path of nodes to this. The
///       /// reverse of ancestors.
///       Iterable<Node> path = ancestors.toList().reversed();
///     }
///
class GeneratingIterable<T> extends IterableBase<T> {
  GeneratingIterable(this._initial, this._next);

  final T Function() _initial;
  final T? Function(T value) _next;

  @override
  Iterator<T> get iterator => _GeneratingIterator(_initial(), _next);
}

class _GeneratingIterator<T> implements Iterator<T> {
  _GeneratingIterator(this.object, this.next);

  final T? Function(T value) next;
  T? object;
  bool started = false;

  @override
  T get current {
    final cur = started ? object : null;
    return cur!;
  }

  @override
  bool moveNext() {
    if (object == null) return false;
    if (started) {
      object = next(object!);
    } else {
      started = true;
    }
    return object != null;
  }
}
