library majik.src.etcd;

import 'dart:async';
import 'dart:convert';
import 'package:ezetcd/ezetcd.dart' as ez;
import 'registry.dart';

class EtcdRegistry implements MajikRegistry {
  
    static const Duration heartbeat = const Duration(seconds:1);
  
    final ez.EtcdClient _client;
    final String _path;

    EtcdRegistry({host: '127.0.0.1', port: 4001, path: '/majik'})
        : this._path = path,
          this._client = new ez.EtcdClient(host: host, port: port) {
    }

    @override
    close() {
      _client.close();
    }
  
  @override
  Future<FrontendRegistration> registerFrontend(String host, int port, Map labels) {
    var completer = new Completer();
    var value = _toNodeJson(NodeType.FRONTEND, host, port, labels);
    var path = _buildPath(_path, host, port);
    
    _client.setNode(path, value: value).then((ez.NodeEvent ne){
      
      var timer = new Timer.periodic(heartbeat, (_){
           _client.setNode(path,value: value, ttl: new Duration(seconds: heartbeat.inSeconds+1));
         });
      completer.complete(_nodeEventToRegistration(ne, timer));
    });
    return completer.future;
  }

  @override
  Future<BackendRegistration> registerBackend(String host, int port, Map labels) {
    var completer = new Completer();
    completer.complete(new _BackendRegistration(host, port, labels));
    return completer.future;
  }

   static bool _matches(Map<String, String> labels, ListingEvent e) {
     var matches = true;
     for (var key in labels.keys) {
       if (!e.listing.labels.containsKey(key) || e.listing.labels[key] != labels[key]) {
         matches = false;
         break;
       }
     }
     return matches;
   }


  static String _toNodeJson(NodeType type, String host, int port, Map labels){
    return JSON.encode({'type': _nodeTypeToString(type), 'host': host, 'port': port, 'labels':labels});
  }
  
  static String _nodeTypeToString(NodeType type){
    switch(type){
      case NodeType.BACKEND:
        return 'backend';
      default:
        return 'frontend';
    }
  }
  
  static FrontendRegistration _nodeEventToRegistration( ez.NodeEvent ne, ){
    return new _NodeRegistration(ne.newValue.key, ne.newValue.value, heartbeat, client);
  }
  
  static String _buildPath(String root, String host, int port){
    return '${root}/${host}_${port}';
  }
  
}

class _FrontendRegistration implements FrontendRegistration {
  
  final Function _onCancel;
  final Stream<NodeEvent> _events;
  final Map<String, String> _labels;
  StreamController _controller;
  
  _FrontendRegistration(this._labels, this._onCancel, this._events){
    _controller = new StreamController(onListen: _observed, onCancel:_unobserved);
  }
  
  cancel(){
    _controller.close;
    _onCancel();
  }

  @override
  Stream<NodeEvent> watchBackends() {
    // TODO: implement watchBackends
  }
  
  _observed(){
    
  }
  
  _unobserved(){
    
  }
  
}

class _BackendRegistration implements BackendRegistration {
  
  @override
  cancel() {
    // TODO: implement cancel
  }

  @override
  Stream<NodeEvent> watchFrontends() {
    // TODO: implement watchFrontends
  }
}