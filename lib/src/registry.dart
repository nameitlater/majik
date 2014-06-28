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

class NodeEvent {
  final NodeEventType type;
  final Node node;
  
  NodeEvent(this.type, this.node);
  
}

class Node {
   final NodeType type;
   final String host;
   final int port;
   final Map labels;
   
   Node(this.type, this.host, this.port, this.labels);
}

abstract class FrontendRegistration {
  Stream<NodeEvent> watchBackends();
  cancel();
}

abstract class BackendRegistration {
  Stream<NodeEvent> watchFrontends();
  cancel();
}


abstract class MajikRegistry {
  Future<FrontendRegistration> registerFrontend(String host, int port, Map labels);
  Future<BackendRegistration> registerBackend(String host, int port, Map labels);
  close();
}