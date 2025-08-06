import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/bubble_word_provider.dart';
import '../models/bubble_word_models.dart';
import '../components/unified_header.dart';

class BubbleWordView extends StatefulWidget {
  const BubbleWordView({super.key});

  @override
  State<BubbleWordView> createState() => _BubbleWordViewState();
}

class _BubbleWordViewState extends State<BubbleWordView> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _definitionController = TextEditingController();
  bool _showingAddWord = false;
  bool _showingEditWord = false;
  WordNode? _editingNode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BubbleWordProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _wordController.dispose();
    _definitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BubbleWordProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Stack(
            children: [
              // Main content
              Column(
                children: [
                  // Header
                  UnifiedHeader(
                    title: provider.currentMap?.name ?? 'Bubble Word',
                    onBack: () => _showSavePrompt(context),
                    trailing: _buildTrailingMenu(context, provider),
                  ),
                  
                  // Action buttons
                  _buildActionButtons(provider),
                  
                  // Canvas
                  Expanded(
                    child: _buildCanvas(provider),
                  ),
                ],
              ),
              
              // Zoom controls
              _buildZoomControls(provider),
            ],
          ),
          
          // Floating action button for adding words
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddWordDialog(context),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildTrailingMenu(BuildContext context, BubbleWordProvider provider) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuAction(value, context, provider),
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
    );
  }

  Widget _buildActionButtons(BubbleWordProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Undo button
          IconButton(
            onPressed: provider.canUndo ? provider.undo : null,
            icon: Icon(
              Icons.undo,
              color: provider.canUndo ? Colors.orange : Colors.grey,
            ),
          ),
          
          // Redo button
          IconButton(
            onPressed: provider.canRedo ? provider.redo : null,
            icon: Icon(
              Icons.redo,
              color: provider.canRedo ? Colors.purple : Colors.grey,
            ),
          ),
          
          const Spacer(),
          
          // Disconnect button (only show when a node is selected)
          if (provider.selectedNodeId != null)
            TextButton.icon(
              onPressed: () => _showDisconnectDialog(context, provider),
              icon: const Icon(Icons.link_off),
              label: const Text('Disconnect'),
            ),
        ],
      ),
    );
  }

  Widget _buildCanvas(BubbleWordProvider provider) {
    return GestureDetector(
      onScaleUpdate: (details) {
        // Handle both scale and pan in the scale gesture
        if (details.scale != 1.0) {
          final newScale = provider.scale * details.scale;
          provider.setScale(newScale);
        }
        if (details.focalPointDelta != Offset.zero) {
          final newOffset = provider.offset + details.focalPointDelta;
          provider.setOffset(newOffset);
        }
      },
      onTapUp: (details) {
        // Deselect if tapping on empty space
        if (provider.selectedNodeId != null) {
          provider.selectNode(null);
        }
      },
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Transform.scale(
          scale: provider.scale,
          child: Transform.translate(
            offset: provider.offset,
            child: Stack(
              children: [
                // Connections
                ...provider.connections.map((connection) => _buildConnection(connection, provider)),
                
                // Word bubbles
                ...provider.nodes.map((node) => _buildWordBubble(node, provider)),
                
                // Connection preview
                if (provider.isConnecting && provider.firstSelectedNodeId != null)
                  _buildConnectionPreview(provider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnection(WordConnection connection, BubbleWordProvider provider) {
    final fromNode = provider.nodes.firstWhere((node) => node.id == connection.fromNodeId);
    final toNode = provider.nodes.firstWhere((node) => node.id == connection.toNodeId);
    
    return CustomPaint(
      painter: ConnectionPainter(
        from: fromNode.position,
        to: toNode.position,
        color: connection.color,
      ),
    );
  }

  Widget _buildConnectionPreview(BubbleWordProvider provider) {
    if (provider.firstSelectedNodeId == null) return const SizedBox.shrink();
    
    final firstNode = provider.nodes.firstWhere((node) => node.id == provider.firstSelectedNodeId);
    
    return CustomPaint(
      painter: ConnectionPreviewPainter(
        from: firstNode.position,
        color: Colors.grey.withOpacity(0.5),
      ),
    );
  }

  Widget _buildWordBubble(WordNode node, BubbleWordProvider provider) {
    final isSelected = provider.selectedNodeId == node.id;
    final isConnecting = provider.isConnecting && provider.firstSelectedNodeId == node.id;
    
    return Positioned(
      left: node.position.dx - node.size / 2,
      top: node.position.dy - node.size / 2,
      child: GestureDetector(
        onTap: () => _handleNodeTap(node, provider),
        onDoubleTap: () => _showEditWordDialog(context, node),
        onPanUpdate: (details) {
          final newPosition = node.position + details.delta;
          provider.updateNode(node.id, position: newPosition);
        },
        child: Container(
          width: node.size,
          height: node.size,
          decoration: BoxDecoration(
            color: node.color,
            borderRadius: BorderRadius.circular(20),
            border: isSelected || isConnecting
                ? Border.all(color: Colors.white, width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                node.word,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControls(BubbleWordProvider provider) {
    return Positioned(
      bottom: 32,
      right: 20,
      child: Column(
        children: [
          // Zoom in
          FloatingActionButton.small(
            onPressed: () {
              final newScale = (provider.scale * 1.2).clamp(0.5, 3.0);
              provider.setScale(newScale);
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.zoom_in, color: Colors.blue),
          ),
          
          const SizedBox(height: 8),
          
          // Zoom out
          FloatingActionButton.small(
            onPressed: () {
              final newScale = (provider.scale / 1.2).clamp(0.5, 3.0);
              provider.setScale(newScale);
            },
            backgroundColor: Colors.white,
            child: const Icon(Icons.zoom_out, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  void _handleNodeTap(WordNode node, BubbleWordProvider provider) {
    if (provider.isConnecting) {
      provider.completeConnection(node.id);
    } else {
      provider.selectNode(node.id);
    }
  }

  void _handleMenuAction(String action, BuildContext context, BubbleWordProvider provider) {
    switch (action) {
      case 'add':
        _showAddWordDialog(context);
        break;
      case 'reset':
        provider.resetView();
        break;
      case 'clear':
        _showClearAllDialog(context, provider);
        break;
    }
  }

  void _showAddWordDialog(BuildContext context) {
    _wordController.clear();
    _definitionController.clear();
    _showingAddWord = true;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Word'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _wordController,
              decoration: const InputDecoration(
                labelText: 'Word',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _definitionController,
              decoration: const InputDecoration(
                labelText: 'Definition',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              if (_wordController.text.isNotEmpty) {
                final provider = context.read<BubbleWordProvider>();
                final random = Random();
                final position = Offset(
                  random.nextDouble() * 300 + 100,
                  random.nextDouble() * 300 + 100,
                );
                provider.addNode(
                  _wordController.text.trim(),
                  _definitionController.text.trim(),
                  position,
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add Word'),
          ),
        ],
      ),
    );
  }

  void _showEditWordDialog(BuildContext context, WordNode node) {
    _wordController.text = node.word;
    _definitionController.text = node.definition;
    _editingNode = node;
    _showingEditWord = true;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Word'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _wordController,
              decoration: const InputDecoration(
                labelText: 'Word',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _definitionController,
              decoration: const InputDecoration(
                labelText: 'Definition',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              if (_wordController.text.isNotEmpty && _editingNode != null) {
                final provider = context.read<BubbleWordProvider>();
                provider.updateNode(
                  _editingNode!.id,
                  word: _wordController.text.trim(),
                  definition: _definitionController.text.trim(),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context, BubbleWordProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Node'),
        content: const Text('Are you sure you want to disconnect all connections for this node?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (provider.selectedNodeId != null) {
                provider.deleteConnectionsForNode(provider.selectedNodeId!);
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, BubbleWordProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Are you sure you want to clear all words and connections? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearAll();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showSavePrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Changes?'),
        content: const Text('Do you want to save your changes before leaving?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Don\'t Save'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Custom painters for connections
class ConnectionPainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final Color color;

  ConnectionPainter({
    required this.from,
    required this.to,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(from, to, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConnectionPreviewPainter extends CustomPainter {
  final Offset from;
  final Color color;

  ConnectionPreviewPainter({
    required this.from,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw a dashed line from the first node to the current mouse position
    // For now, just draw a line to the center of the screen
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(from, center, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 