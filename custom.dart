// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// For clarity, this example uses the text representation of the sample remote
/// widget library, and parses it locally. To do this, [parseLibraryFile] is
/// used. In production, this is strongly discouraged since it is 10x slower
/// than using [decodeLibraryBlob] to parse the binary version of the format.
import 'package:rfw/formats.dart' show parseLibraryFile;

import 'package:rfw/rfw.dart';

void main() {
  runApp(const Example());
}

class Example extends StatefulWidget {
  const Example({Key? key}) : super(key: key);

  @override
  State<Example> createState() => _ExampleState();
}

class _ExampleState extends State<Example> {
//!----------------------------01 - Make Runtime--------------------------------
  final Runtime _runtime = Runtime();
  final DynamicContent _data = DynamicContent();

  @override
  void initState() {
    _update();
  }

  static const LibraryName localName = LibraryName(<String>['local']);
  static const LibraryName remoteName = LibraryName(<String>['remote']);

  void _update() {
    _runtime.update(localName, _createLocalWidgets());
    // Normally we would obtain the remote widget library in binary form from a
    // server, and decode it with [decodeLibraryBlob] rather than parsing the
    // text version using [parseLibraryFile]. However, to make it easier to
    // play with this sample, this uses the slower text format.
    _runtime.update(remoteName, parseLibraryFile('''
      import local;
      widget root = GreenBox(
        child: MathWidget(name: "World"),
      );
    '''));
  }

  static WidgetLibrary _createLocalWidgets() {
    return LocalWidgetLibrary(<String, LocalWidgetBuilder>{
      'GreenBox':
          //
          (BuildContext context, DataSource source) {
        return Container(
          color: const Color(0xFF002211),
          child: source.child(<Object>['child']),
        );
      },
      'MathWidget': (BuildContext context, DataSource source) {
        return Math.tex(
          r'\int u \frac{dv}{dx}\,dx=uv-\int \frac{du}{dx}v\,dx',
          textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
        ); 
      },
    });
  }

//!--------------------------02 - Using RemoteWidget----------------------------
  @override
  Widget build(BuildContext context) {
    return RemoteWidget(
      runtime: _runtime,
      data: _data,
      widget: const FullyQualifiedWidgetName(remoteName, 'root'),
    );
  }
}
