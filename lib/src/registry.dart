library majik.src.registry;

import 'dart:async';

class NodeType {
  const NodeType._();
  static const NodeType FRONTEND = const NodeType._();
  static const NodeType BACKEND = const NodeType._();
}

class NodeEventType {
  const NodeEventType._();
  static const NodeEventType ADDED = const NodeEventType._();
  static const NodeEventType REMOVED = const NodeEventType._();
}

class Backend {
   final NodeType type;
   final String host;
   final int port;
   final Map labels;
   final int weight;
   
   Backend(this.type, this.host, this.port, this.labels, this.weight);
}

class BackendEvent {
  final NodeEventType type;
  final Backend node;
  
  BackendEvent(this.type, this.node);
  
}

class Frontend {
   final NodeType type;
   final String host;
   final int port;
   final Map labels;
   
   Frontend(this.type, this.host, this.port, this.labels);
}

class FrontendEvent {
  final NodeEventType type;
  final Frontend node;
  
  FrontendEvent(this.type, this.node);
  
}

abstract class FrontendRegistration {
  Stream<FrontendEvent> watchBackends();
  cancel();
}

abstract class BackendRegistration {
  Stream<BackendEvent> watchFrontends();
  cancel();
}


abstract class MajikRegistry {
  Future<FrontendRegistration> registerFrontend(String host, int port, Map labels);
  Future<BackendRegistration> registerBackend(String host, int port, Map labels);
  close();
}