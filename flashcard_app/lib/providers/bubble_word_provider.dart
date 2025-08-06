import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/bubble_word_models.dart';

class BubbleWordProvider extends ChangeNotifier {
  static final BubbleWordProvider _instance = BubbleWordProvider._internal();
  factory BubbleWordProvider() => _instance;
  BubbleWordProvider._internal();

  List<BubbleWordMap> _maps = [];
  String? _selectedMapId;
  String? _selectedNodeId;
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _lastOffset = Offset.zero;
  bool _isConnecting = false;
  String? _firstSelectedNodeId;
  
  // Overlay functionality
  Set<String> _overlayMapIds = {};

  // Undo/Redo functionality
  List<BubbleWordMap> _undoStack = [];
  List<BubbleWordMap> _redoStack = [];
  static const int maxUndoSteps = 20;

  // Color palette
  final List<Color> _bubbleColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.pink,
    Colors.yellow,
    Colors.teal,
    Colors.indigo,
  ];

  // Getters
  List<BubbleWordMap> get maps => _maps;
  String? get selectedMapId => _selectedMapId;
  String? get selectedNodeId => _selectedNodeId;
  double get scale => _scale;
  Offset get offset => _offset;
  bool get isConnecting => _isConnecting;
  String? get firstSelectedNodeId => _firstSelectedNodeId;

  BubbleWordMap? get currentMap {
    if (_selectedMapId == null) return null;
    return _maps.firstWhere(
      (map) => map.id == _selectedMapId,
      orElse: () => _maps.first,
    );
  }

  List<WordNode> get nodes {
    final nodes = <WordNode>[];
    // Add nodes from current map
    if (currentMap != null) {
      nodes.addAll(currentMap!.nodes);
    }
    // Add nodes from overlay maps
    for (final mapId in _overlayMapIds) {
      final overlayMap = _maps.firstWhere((map) => map.id == mapId);
      nodes.addAll(overlayMap.nodes);
    }
    return nodes;
  }
  
  List<WordConnection> get connections {
    final connections = <WordConnection>[];
    // Add connections from current map
    if (currentMap != null) {
      connections.addAll(currentMap!.connections);
    }
    // Add connections from overlay maps
    for (final mapId in _overlayMapIds) {
      final overlayMap = _maps.firstWhere((map) => map.id == mapId);
      connections.addAll(overlayMap.connections);
    }
    return connections;
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
  
  Set<String> get overlayMapIds => _overlayMapIds;

  // Initialize
  Future<void> initialize() async {
    await loadData();
    if (_maps.isEmpty) {
      createDefaultMap();
    }
    if (_selectedMapId == null && _maps.isNotEmpty) {
      _selectedMapId = _maps.first.id;
    }
  }

  // Map Management
  BubbleWordMap createMap(String name) {
    final newMap = BubbleWordMap(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _maps.add(newMap);
    _selectedMapId = newMap.id;
    saveData();
    notifyListeners();
    return newMap;
  }

  void deleteMap(String mapId) {
    _maps.removeWhere((map) => map.id == mapId);
    if (_selectedMapId == mapId) {
      _selectedMapId = _maps.isNotEmpty ? _maps.first.id : null;
    }
    saveData();
    notifyListeners();
  }

  void selectMap(String mapId) {
    _selectedMapId = mapId;
    _scale = 1.0;
    _offset = Offset.zero;
    _lastOffset = Offset.zero;
    _selectedNodeId = null;
    _isConnecting = false;
    _firstSelectedNodeId = null;
    saveData();
    notifyListeners();
  }

  void toggleOverlay(String mapId) {
    if (_overlayMapIds.contains(mapId)) {
      _overlayMapIds.remove(mapId);
    } else {
      _overlayMapIds.add(mapId);
    }
    saveData();
    notifyListeners();
  }

  void clearOverlays() {
    _overlayMapIds.clear();
    saveData();
    notifyListeners();
  }

  void createDefaultMap() {
    final defaultMap = BubbleWordMap(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: "My First Map",
    );
    _maps.add(defaultMap);
    _selectedMapId = defaultMap.id;
    saveData();
    notifyListeners();
  }

  // Node Management
  void addNode(String word, String definition, Offset position) {
    if (currentMap == null) return;

    final node = WordNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      word: word,
      definition: definition,
      color: _bubbleColors[Random().nextInt(_bubbleColors.length)],
      position: position,
    );

    _saveStateForUndo();
    
    final updatedMap = currentMap!.copyWith(
      nodes: [...currentMap!.nodes, node],
      updatedAt: DateTime.now(),
    );
    
    _updateMap(updatedMap);
    saveData();
    notifyListeners();
  }

  void updateNode(String nodeId, {String? word, String? definition, Offset? position}) {
    if (currentMap == null) return;

    final nodeIndex = currentMap!.nodes.indexWhere((node) => node.id == nodeId);
    if (nodeIndex == -1) return;

    _saveStateForUndo();

    final updatedNodes = List<WordNode>.from(currentMap!.nodes);
    final oldNode = updatedNodes[nodeIndex];
    updatedNodes[nodeIndex] = oldNode.copyWith(
      word: word ?? oldNode.word,
      definition: definition ?? oldNode.definition,
      position: position ?? oldNode.position,
    );

    final updatedMap = currentMap!.copyWith(
      nodes: updatedNodes,
      updatedAt: DateTime.now(),
    );

    _updateMap(updatedMap);
    saveData();
    notifyListeners();
  }

  void deleteNode(String nodeId) {
    if (currentMap == null) return;

    _saveStateForUndo();

    // Remove the node
    final updatedNodes = currentMap!.nodes.where((node) => node.id != nodeId).toList();
    
    // Remove connections involving this node
    final updatedConnections = currentMap!.connections
        .where((conn) => conn.fromNodeId != nodeId && conn.toNodeId != nodeId)
        .toList();

    final updatedMap = currentMap!.copyWith(
      nodes: updatedNodes,
      connections: updatedConnections,
      updatedAt: DateTime.now(),
    );

    _updateMap(updatedMap);
    _selectedNodeId = null;
    _isConnecting = false;
    _firstSelectedNodeId = null;
    saveData();
    notifyListeners();
  }

  // Connection Management
  void addConnection(String fromNodeId, String toNodeId) {
    if (currentMap == null) return;
    if (fromNodeId == toNodeId) return;

    // Check if connection already exists
    final existingConnection = currentMap!.connections.any(
      (conn) => (conn.fromNodeId == fromNodeId && conn.toNodeId == toNodeId) ||
                 (conn.fromNodeId == toNodeId && conn.toNodeId == fromNodeId),
    );

    if (existingConnection) return;

    _saveStateForUndo();

    final connection = WordConnection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      color: Colors.grey,
    );

    final updatedMap = currentMap!.copyWith(
      connections: [...currentMap!.connections, connection],
      updatedAt: DateTime.now(),
    );

    _updateMap(updatedMap);
    saveData();
    notifyListeners();
  }

  void deleteConnection(String connectionId) {
    if (currentMap == null) return;

    _saveStateForUndo();

    final updatedConnections = currentMap!.connections
        .where((conn) => conn.id != connectionId)
        .toList();

    final updatedMap = currentMap!.copyWith(
      connections: updatedConnections,
      updatedAt: DateTime.now(),
    );

    _updateMap(updatedMap);
    saveData();
    notifyListeners();
  }

  void deleteConnectionsForNode(String nodeId) {
    if (currentMap == null) return;

    _saveStateForUndo();

    final updatedConnections = currentMap!.connections
        .where((conn) => conn.fromNodeId != nodeId && conn.toNodeId != nodeId)
        .toList();

    final updatedMap = currentMap!.copyWith(
      connections: updatedConnections,
      updatedAt: DateTime.now(),
    );

    _updateMap(updatedMap);
    saveData();
    notifyListeners();
  }

  // Selection Management
  void selectNode(String? nodeId) {
    _selectedNodeId = nodeId;
    notifyListeners();
  }

  void startConnection(String nodeId) {
    _isConnecting = true;
    _firstSelectedNodeId = nodeId;
    notifyListeners();
  }

  void completeConnection(String nodeId) {
    if (_firstSelectedNodeId != null && _firstSelectedNodeId != nodeId) {
      addConnection(_firstSelectedNodeId!, nodeId);
    }
    _isConnecting = false;
    _firstSelectedNodeId = null;
    notifyListeners();
  }

  void cancelConnection() {
    _isConnecting = false;
    _firstSelectedNodeId = null;
    notifyListeners();
  }

  // View Management
  void setScale(double scale) {
    _scale = scale.clamp(0.5, 3.0);
    notifyListeners();
  }

  void setOffset(Offset offset) {
    _offset = offset;
    notifyListeners();
  }

  void resetView() {
    _scale = 1.0;
    _offset = Offset.zero;
    _lastOffset = Offset.zero;
    notifyListeners();
  }

  // Undo/Redo
  void _saveStateForUndo() {
    if (currentMap == null) return;

    _undoStack.add(currentMap!);
    if (_undoStack.length > maxUndoSteps) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  void undo() {
    if (!canUndo || currentMap == null) return;

    _redoStack.add(currentMap!);
    final previousState = _undoStack.removeLast();
    
    final mapIndex = _maps.indexWhere((map) => map.id == currentMap!.id);
    if (mapIndex != -1) {
      _maps[mapIndex] = previousState;
    }

    saveData();
    notifyListeners();
  }

  void redo() {
    if (!canRedo || currentMap == null) return;

    _undoStack.add(currentMap!);
    final nextState = _redoStack.removeLast();
    
    final mapIndex = _maps.indexWhere((map) => map.id == currentMap!.id);
    if (mapIndex != -1) {
      _maps[mapIndex] = nextState;
    }

    saveData();
    notifyListeners();
  }

  // Helper Methods
  void _updateMap(BubbleWordMap updatedMap) {
    final mapIndex = _maps.indexWhere((map) => map.id == updatedMap.id);
    if (mapIndex != -1) {
      _maps[mapIndex] = updatedMap;
    }
  }

  // Persistence
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final mapsJson = _maps.map((map) => map.toJson()).toList();
    await prefs.setString('BubbleWordMaps', jsonEncode(mapsJson));
    await prefs.setString('BubbleWordSelectedMap', _selectedMapId ?? '');
    await prefs.setStringList('BubbleWordOverlayMaps', _overlayMapIds.toList());
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final mapsString = prefs.getString('BubbleWordMaps');
    if (mapsString != null) {
      try {
        final mapsJson = jsonDecode(mapsString) as List<dynamic>;
        _maps = mapsJson.map((json) => BubbleWordMap.fromJson(json)).toList();
      } catch (e) {
        print('Error loading bubble word maps: $e');
        _maps = [];
      }
    }

    _selectedMapId = prefs.getString('BubbleWordSelectedMap');
    
    final overlayMaps = prefs.getStringList('BubbleWordOverlayMaps');
    if (overlayMaps != null) {
      _overlayMapIds = overlayMaps.toSet();
    }
  }

  // Clear all data
  void clearAll() {
    _saveStateForUndo();
    
    final updatedMap = currentMap?.copyWith(
      nodes: [],
      connections: [],
      updatedAt: DateTime.now(),
    );
    
    if (updatedMap != null) {
      _updateMap(updatedMap);
    }
    
    _selectedNodeId = null;
    _isConnecting = false;
    _firstSelectedNodeId = null;
    saveData();
    notifyListeners();
  }
} 