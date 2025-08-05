import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/flashcard_provider.dart';
import '../models/flash_card.dart';
import '../components/unified_header.dart';

class WordNode {
  final String id;
  final String word;
  final String definition;
  final Color color;
  final Offset position;
  final double size;
  bool isSelected;
  bool isDragging;

  WordNode({
    required this.id,
    required this.word,
    required this.definition,
    required this.color,
    required this.position,
    this.size = 80,
    this.isSelected = false,
    this.isDragging = false,
  });

  WordNode copyWith({
    String? id,
    String? word,
    String? definition,
    Color? color,
    Offset? position,
    double? size,
    bool? isSelected,
    bool? isDragging,
  }) {
    return WordNode(
      id: id ?? this.id,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      color: color ?? this.color,
      position: position ?? this.position,
      size: size ?? this.size,
      isSelected: isSelected ?? this.isSelected,
      isDragging: isDragging ?? this.isDragging,
    );
  }
}

class WordConnection {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final Color color;

  WordConnection({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.color,
  });
}

class BubbleWordView extends StatefulWidget {
  const BubbleWordView({super.key});

  @override
  State<BubbleWordView> createState() => _BubbleWordViewState();
}

class _BubbleWordViewState extends State<BubbleWordView> {
  final List<WordNode> _nodes = [];
  final List<WordConnection> _connections = [];
  final Random _random = Random();
  
  Offset _panOffset = Offset.zero;
  double _scale = 1.0;
  String? _selectedNodeId;
  String? _firstSelectedNodeId;
  bool _isConnecting = false;
  
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

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    // Add some sample word nodes
    _addWordNode('huis', 'house', const Offset(100, 100));
    _addWordNode('auto', 'car', const Offset(300, 150));
    _addWordNode('boek', 'book', const Offset(200, 300));
    _addWordNode('hond', 'dog', const Offset(400, 250));
    _addWordNode('kat', 'cat', const Offset(150, 400));
  }

  void _addWordNode(String word, String definition, Offset position) {
    final node = WordNode(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      word: word,
      definition: definition,
      color: _bubbleColors[_random.nextInt(_bubbleColors.length)],
      position: position,
    );
    setState(() {
      _nodes.add(node);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          UnifiedHeader(
            title: 'Bubble Word',
            onBack: () => Navigator.of(context).pop(),
            trailing: PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'add',
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text('Add Word'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Reset View'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Clear All', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Toolbar
          _buildToolbar(),
          
          // Canvas
          Expanded(
            child: GestureDetector(
              onPanUpdate: _handlePanUpdate,
              onScaleUpdate: _handleScaleUpdate,
              onTapUp: _handleCanvasTap,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                child: Stack(
                  children: [
                    // Connections
                    ..._buildConnections(),
                    
                    // Word bubbles
                    ..._buildWordBubbles(),
                    
                    // Connection preview
                    if (_isConnecting && _firstSelectedNodeId != null)
                      _buildConnectionPreview(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWordDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _zoomIn,
            icon: const Icon(Icons.zoom_in),
            tooltip: 'Zoom In',
          ),
          IconButton(
            onPressed: _zoomOut,
            icon: const Icon(Icons.zoom_out),
            tooltip: 'Zoom Out',
          ),
          IconButton(
            onPressed: _resetView,
            icon: const Icon(Icons.center_focus_strong),
            tooltip: 'Reset View',
          ),
          IconButton(
            onPressed: _undo,
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
          ),
          IconButton(
            onPressed: _redo,
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConnections() {
    return _connections.map((connection) {
      final fromNode = _nodes.firstWhere((node) => node.id == connection.fromNodeId);
      final toNode = _nodes.firstWhere((node) => node.id == connection.toNodeId);
      
      return CustomPaint(
        painter: ConnectionPainter(
          from: fromNode.position + _panOffset,
          to: toNode.position + _panOffset,
          color: connection.color,
          scale: _scale,
        ),
      );
    }).toList();
  }

  List<Widget> _buildWordBubbles() {
    return _nodes.map((node) {
      return Positioned(
        left: (node.position.dx + _panOffset.dx) * _scale,
        top: (node.position.dy + _panOffset.dy) * _scale,
        child: GestureDetector(
          onPanUpdate: (details) => _handleNodeDrag(node, details),
          onTap: () => _handleNodeTap(node),
          onDoubleTap: () => _handleNodeDoubleTap(node),
          child: Transform.scale(
            scale: _scale,
            child: _buildWordBubble(node),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildWordBubble(WordNode node) {
    return Container(
      width: node.size,
      height: node.size,
      decoration: BoxDecoration(
        color: node.color.withValues(alpha: node.isSelected ? 0.8 : 0.6),
        shape: BoxShape.circle,
        border: Border.all(
          color: node.isSelected ? Colors.white : Colors.transparent,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: node.color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              node.word,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (node.isSelected) ...[
              const SizedBox(height: 4),
              Text(
                node.definition,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionPreview() {
    if (_firstSelectedNodeId == null) return const SizedBox.shrink();
    
    final firstNode = _nodes.firstWhere((node) => node.id == _firstSelectedNodeId);
    
    return Positioned(
      left: (firstNode.position.dx + _panOffset.dx) * _scale,
      top: (firstNode.position.dy + _panOffset.dy) * _scale,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.link,
            color: Colors.white,
            size: 12,
          ),
        ),
      ),
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _panOffset += details.delta;
    });
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_scale * details.scale).clamp(0.5, 3.0);
    });
  }

  void _handleCanvasTap(TapUpDetails details) {
    // Clear selection when tapping empty space
    setState(() {
      _selectedNodeId = null;
      _isConnecting = false;
      _firstSelectedNodeId = null;
      
      // Clear all node selections
      for (int i = 0; i < _nodes.length; i++) {
        _nodes[i] = _nodes[i].copyWith(isSelected: false);
      }
    });
  }

  void _handleNodeDrag(WordNode node, DragUpdateDetails details) {
    setState(() {
      final index = _nodes.indexWhere((n) => n.id == node.id);
      if (index != -1) {
        _nodes[index] = node.copyWith(
          position: node.position + details.delta / _scale,
          isDragging: true,
        );
      }
    });
  }

  void _handleNodeTap(WordNode node) {
    setState(() {
      // Clear other selections
      for (int i = 0; i < _nodes.length; i++) {
        _nodes[i] = _nodes[i].copyWith(isSelected: false);
      }
      
      // Select this node
      final index = _nodes.indexWhere((n) => n.id == node.id);
      if (index != -1) {
        _nodes[index] = _nodes[index].copyWith(isSelected: true);
        _selectedNodeId = node.id;
      }
      
      // Handle connection logic
      if (_isConnecting && _firstSelectedNodeId != null && _firstSelectedNodeId != node.id) {
        _createConnection(_firstSelectedNodeId!, node.id);
        _isConnecting = false;
        _firstSelectedNodeId = null;
      } else if (!_isConnecting) {
        _firstSelectedNodeId = node.id;
        _isConnecting = true;
      }
    });
  }

  void _handleNodeDoubleTap(WordNode node) {
    _showEditWordDialog(node);
  }

  void _createConnection(String fromId, String toId) {
    final connection = WordConnection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fromNodeId: fromId,
      toNodeId: toId,
      color: Colors.blue,
    );
    setState(() {
      _connections.add(connection);
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'add':
        _showAddWordDialog();
        break;
      case 'reset':
        _resetView();
        break;
      case 'clear':
        _showClearAllDialog();
        break;
    }
  }

  void _showAddWordDialog() {
    final wordController = TextEditingController();
    final definitionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Word'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wordController,
              decoration: const InputDecoration(
                labelText: 'Dutch Word',
                hintText: 'e.g., huis',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: definitionController,
              decoration: const InputDecoration(
                labelText: 'Definition',
                hintText: 'e.g., house',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (wordController.text.isNotEmpty && definitionController.text.isNotEmpty) {
                final position = Offset(
                  100 + _random.nextDouble() * 200,
                  100 + _random.nextDouble() * 200,
                );
                _addWordNode(
                  wordController.text.trim(),
                  definitionController.text.trim(),
                  position,
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditWordDialog(WordNode node) {
    final wordController = TextEditingController(text: node.word);
    final definitionController = TextEditingController(text: node.definition);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Word'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: wordController,
              decoration: const InputDecoration(
                labelText: 'Dutch Word',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: definitionController,
              decoration: const InputDecoration(
                labelText: 'Definition',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (wordController.text.isNotEmpty && definitionController.text.isNotEmpty) {
                setState(() {
                  final index = _nodes.indexWhere((n) => n.id == node.id);
                  if (index != -1) {
                    _nodes[index] = _nodes[index].copyWith(
                      word: wordController.text.trim(),
                      definition: definitionController.text.trim(),
                    );
                  }
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Are you sure you want to clear all words and connections?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _nodes.clear();
                _connections.clear();
                _selectedNodeId = null;
                _isConnecting = false;
                _firstSelectedNodeId = null;
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _zoomIn() {
    setState(() {
      _scale = (_scale * 1.2).clamp(0.5, 3.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _scale = (_scale / 1.2).clamp(0.5, 3.0);
    });
  }

  void _resetView() {
    setState(() {
      _panOffset = Offset.zero;
      _scale = 1.0;
    });
  }

  void _undo() {
    // TODO: Implement undo functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Undo coming soon!')),
    );
  }

  void _redo() {
    // TODO: Implement redo functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redo coming soon!')),
    );
  }
}

class ConnectionPainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final Color color;
  final double scale;

  ConnectionPainter({
    required this.from,
    required this.to,
    required this.color,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2 * scale
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(from, to, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 