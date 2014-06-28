library majik.src.frontend;

import 'dart:async';
import 'dart:io';
//import 'package:eureka/eureka.dart';
//import 'package:eureka/etcd.dart';
import 'registry.dart';
import 'etcd.dart';
import 'package:mustache/mustache.dart' as mustache;

const String HAPROXY_CONFIG_FILE = '/etc/haproxy/haproxy.cfg';

const String _TCP_TEMPLATE = '''

''';

const String _TCP_DEFAULT_CONFIG = '''

''';

const String _WEBSOCKET_TEMPLATE = '''

''';

const String _WEBSOCKET_DEFAULT_CONFIG = '''

''';

const String _HTTP_TEMPLATE = '''

frontend web 
bind *:80
mode http
default_backend web

backend web
mode http
balance roundrobin 
{{#servers}}
server {{name}} {{authority}}
{{/servers}}

''';

const String _HTTP_DEFAULT_CONFIG = '''

''';

class Mode {
  const Mode._();

  static const Mode HTTP = const Mode._();
  static const Mode WEBSOCKET = const Mode._();
  static const Mode TCP = const Mode._();

}

main(Map<String, String> labels, {Mode mode : Mode.HTTP}) {

  _startHaProxy(mode).then((_){
    _watchServices(mode, labels);
  });
  
}

//haproxy -f /etc/haproxy.cfg -p /var/run/haproxy.pid -sf $(cat /var/run/haproxy.pid)
Future _startHaProxy(Mode mode) {
  var file = new File(HAPROXY_CONFIG_FILE);
  file.writeAsStringSync(_defaultConfigForMode(mode));
  return Process.run('haproxy', ['-f', HAPROXY_CONFIG_FILE]);
}

_reloadHaProxy(mustache.Template template, List reload){
  var file = new File(HAPROXY_CONFIG_FILE);
  file.writeAsStringSync(template.renderString(reload.removeAt(0)));
  Process.run('haproxy', ['-f', HAPROXY_CONFIG_FILE, '-p','/var/run/haproxy.pid']).whenComplete((){
    if(reload.isNotEmpty){
      _reloadHaProxy(template, reload);
    }
  });
}

_watchServices(Mode mode, Map<String, String> labels){

  var registry = new EtcdRegistry();
  var template = _templateForMode(mode);
  var listings = {};
  var reload = [];
  registry.watch(labels, NodeType.BACKEND).listen((e) {
    switch(e.type){
      case NodeEventType.REMOVED:
        listings.remove(e.listing.location);
        break;
      default:
        listings[e.listing.location] = {'name':_uriToServerName(e.listing.location),'authority':e.listing.location.authority};
        break;
    } 
   
    if(reload.isEmpty){
       reload[0] = listings;
      _reloadHaProxy(template, reload);
    }else {
      reload = true;
    }
  });
}

String _uriToServerName(Uri uri){
  return '${uri.host}_${uri.port}';
}

mustache.Template _templateForMode(Mode mode) {
  switch (mode) {
    case Mode.WEBSOCKET:
      return mustache.parse(_WEBSOCKET_TEMPLATE);
    case Mode.TCP:
      return mustache.parse(_TCP_TEMPLATE);
    default:
      return mustache.parse(_HTTP_TEMPLATE);
  }
}

String _defaultConfigForMode(Mode mode) {
  switch (mode) {
    case Mode.WEBSOCKET:
      return _WEBSOCKET_DEFAULT_CONFIG;
    case Mode.TCP:
      return _TCP_DEFAULT_CONFIG;
    default:
      return _HTTP_DEFAULT_CONFIG;
  }
}
