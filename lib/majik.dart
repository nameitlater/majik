// Copyright (c) 2014, the Name It Later majik project authors.
// Please see the AUTHORS file for details. All rights reserved. Use of this 
// source code is governed by the BSD 3 Clause license, a copy of which can be
// found in the LICENSE file.

library majik;

import 'package:args/args.dart';

void main(args) {;
  var proxy = new ArgParser();
  proxy.addOption('type', help: 'The type of the proxy', 
      allowed:['frontend, backend'],
      defaultsTo:'frontend', 
      allowedHelp: {'frontend' :'A frontend proxy connected to services matching --label',
        'backend': 'A backend proxy advertising --label'});
  proxy.addOption('label', callback: _validateLabel, help: 'A label associated with the service', allowMultiple:true);
  try {
    var parsedArgs = proxy.parse(args);
    switch(parsedArgs['type']){
      case 'frontend':

        break;
      case 'backend':

    }
  } on FormatException catch(e){
    print(e.message);
    print(proxy.getUsage());
  }
   
}

 final RegExp _WORD = new RegExp(r'\w+');
 
_validateLabel(List<String> labels){
  if(labels != null){
    labels.forEach((label){
      List<Match> matches = _WORD.allMatches(label).toList();
      if(!(matches.length > 0 && matches.length < 3)){
        throw new FormatException('majik: labels are key=value pairs of words or a single word');
      }
      if(matches.length == 2){
        if(matches[0].end+1 != matches[1].start || label.codeUnitAt(matches[0].end) != '='.codeUnitAt(0)){
          throw new FormatException('majik: labels are key=value pairs of words or a single word');
        }
      }

    });
  }
}
