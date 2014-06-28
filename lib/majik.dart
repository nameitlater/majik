// Copyright (c) 2014, the Name It Later majik project authors.
// Please see the AUTHORS file for details. All rights reserved. Use of this
// source code is governed by the BSD 3 Clause license, a copy of which can be
// found in the LICENSE file.

library majik;

import 'package:args/args.dart';
import 'src/frontend.dart' as frontend;

const String _TYPE_OPTION = 'type';
const String _TYPE_FRONTEND = 'frontend';
const String _TYPE_BACKEND = 'backend';

const String _MODE_OPTION = 'mode';
const String _MODE_HTTP = 'http';
const String _MODE_WEBSOCKET = 'websocket';
const String _MODE_TCP = 'tcp';

const String _LABEL_OPTION = 'label';



void main(args) {
  var parser = new ArgParser();
  parser.addOption(_TYPE_OPTION, help: 'The type of the proxy', allowed: [_TYPE_FRONTEND, _TYPE_BACKEND], defaultsTo: _TYPE_FRONTEND, allowedHelp: {
    _TYPE_FRONTEND: 'A frontend proxy connected to services matching --label',
    _TYPE_BACKEND: 'A backend proxy advertising --label'
  });
  
  var labels = {};
  
  parser.addOption(_LABEL_OPTION, callback: (List<String> labelArgs){
    _processLabels(labelArgs, labels);
  }, help: 'A label associated with the service.', allowMultiple: true, defaultsTo:'dev');
  parser.addOption(_MODE_OPTION, help: 'The mode to operate in', allowed: [_MODE_HTTP, _MODE_WEBSOCKET, _MODE_TCP], defaultsTo: _MODE_HTTP, allowedHelp: {
    _MODE_HTTP: 'A proxy for http traffic',
    _MODE_WEBSOCKET: 'A proxy for websocket traffic',
    _MODE_TCP: 'A proxy for arbitrary tcp traffic'
  });
  try {
    var parsedArgs = parser.parse(args);
    switch (parsedArgs[_TYPE_OPTION]) {
      case _TYPE_BACKEND:
        // _runAsBackend(parsedArgs);
        break;
      default:
       frontend.main(labels, mode:_parseMode(parsedArgs[_MODE_OPTION]));
    }
  } on FormatException catch (e) {
    print(e.message);
    print(parser.getUsage());
  }

}

final RegExp _WORD = new RegExp(r'\w+');

_assertWord(String value) {
  var matches = _WORD.allMatches(value);
  if (matches.isEmpty) {
    throw new FormatException('majik: labels are key=value pairs of words or a single word');
  }
}

_processLabels(List<String> rawLabels, Map<String, String> mappedLabels) {
  if (rawLabels != null) {
    rawLabels.forEach((label) {
      var parts = label.split('=');
      if (parts.length == 0 || parts.length > 2) {
        throw new FormatException('majik: labels are key=value pairs of words or a single word');
      } else if (parts.length == 1) {
        _assertWord(parts[0]);
        mappedLabels[parts[0]] = null;
      } else {
        _assertWord(parts[0]);
        _assertWord(parts[1]);
        mappedLabels[parts[0]] = parts[1];
      }

    });
  }
}

_parseMode(String mode){
  switch (mode) {
      case _MODE_WEBSOCKET:
        return frontend.Mode.WEBSOCKET;
      case _MODE_TCP:
        return frontend.Mode.TCP;
      default:
        return frontend.Mode.HTTP;
    }
}

_runAsFrontend(String mode, Map<String, String> labels) {
  switch (mode) {
    case _MODE_WEBSOCKET:
      frontend.main(labels, mode: frontend.Mode.WEBSOCKET);
      break;
    case _MODE_TCP:
      frontend.main(labels, mode: frontend.Mode.TCP);
      break;
    default:
      frontend.main(labels);
  }

}

_runAsBackend(ArgResults args) {
  switch (args[_MODE_OPTION]) {
    case _MODE_WEBSOCKET:
      break;
    case _MODE_TCP:
      break;
    default:
  }
}
