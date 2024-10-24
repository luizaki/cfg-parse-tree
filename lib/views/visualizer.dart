import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class TreeView extends StatefulWidget {
  const TreeView({super.key, required this.cfg});

  final Map<String, dynamic> cfg;

  @override
  _TreeViewState createState() => _TreeViewState(cfg);
}

class _TreeViewState extends State<TreeView> {
  final Map<String, dynamic> cfgJson;

  _TreeViewState(this.cfgJson);

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    super.initState();
    builder
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    Map<int, Node> nodeMap = {};

    for (var nodeData in cfgJson['nodes']!) {
      int id = nodeData['id'] as int;
      String label = nodeData['label'] as String;
      var node = Node.Id(id);
      nodeMap[id] = node;
      graph.addNode(node);
    }

    for (var edgeData in cfgJson['edges']!) {
      int from = edgeData['from'] as int;
      int to = edgeData['to'] as int;
      graph.addEdge(nodeMap[from]!, nodeMap[to]!);
    }

    return Scaffold(
        body: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.01,
              maxScale: 5.6,
              child: GraphView(
                graph: graph,
                algorithm:
                    BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                paint: Paint()
                  ..color = Colors.black
                  ..strokeWidth = 2
                  ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  var id = node.key!.value as int;
                  var nodes = cfgJson['nodes'];
                  var nodeValue =
                      nodes!.firstWhere((element) => element['id'] == id);
                  return nodeWidget(nodeValue['label'] as String);
                },
              )),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go Back'),
        ),
      ],
    ));
  }

// to design each node
  Widget nodeWidget(String label) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(color: Colors.blue, spreadRadius: 1),
          ],
        ),
        child: Text(label));
  }
}
