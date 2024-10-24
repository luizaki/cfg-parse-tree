import 'grammar.dart';
import 'state.dart';
import 'symbol.dart';
import 'tree.dart';

class Chart {
  Grammar grammar;
  String inputString;

  late List<List<State>> chart;

  Chart(this.grammar, this.inputString) {
    // initialize columns
    chart = List.generate(inputString.length + 1, (i) => []);

    // add start state
    chart[0].add(State(grammar.rules[0], 0, 0));
  }

  int length() {
    return chart.length;
  }
}

class Parser {
  Grammar grammar;
  List<TreeNode> allNodes = [];

  Parser(this.grammar);

  dynamic parse(String input) {
    Chart chart = Chart(grammar, input);

    // go over the chart
    var i = 0;
    while (i < chart.length()) {
      var j = 0;

      while (j < chart.chart[i].length) {
        State state = chart.chart[i][j];
        if (!state.isComplete()) {
          if (state.next()!.type == 'T') {
            scan(state, i, input, chart);
          } else {
            predict(state, i, chart);
          }
        } else {
          complete(state, i, chart);
        }

        j++;
      }
      // Debugging output
      print("Chart at index $i: ${chart.chart[i]}");
      i++;
    }

    // check if input is accepted by looking for completed start states
    for (State state in chart.chart[input.length]) {
      if (state.rule.nonTerminal == grammar.startSymbol &&
          state.isComplete() &&
          state.startIndex == 0) {
        var jsonTree = generateTreeJson(state.node);
        print(jsonTree); // This will print the JSON-like structure
        return jsonTree;
      }
    }
    return false;
  }

  // add new states
  void predict(State st, int i, Chart chart) {
    for (Rule rule in grammar.rules) {
      // if rule's left hand (nt) matches the next state's left hand (nt), add to chart
      if (rule.nonTerminal == st.next()!.value) {
        if (rule.isNullable()) {
          var epsilonState = State(st.rule, st.startIndex, st.dot + 1);
          print('Predict $epsilonState');
          chart.chart[i].add(epsilonState);
        } else {
          var newState = State(rule, i, 0);
          print('Predict $newState');
          chart.chart[i].add(newState);
          newState.node = TreeNode(rule.nt);
        }
      }
    }
  }

// move dot if state's right hand matches input
  void scan(State st, int i, String input, Chart chart) {
    if (st.startIndex + st.dot < input.length) {
      if (st.next()!.value == input[st.startIndex + st.dot]) {
        var newState = State(st.rule, st.startIndex, st.dot + 1);

        TreeNode newNode = TreeNode(T(input[st.startIndex + st.dot]));
        newState.node.addChild(newNode);
        print('Scan $newState');
        chart.chart[i + 1].add(newState);
      }
    }
  }

  // finalize state by backtracking the rules
  void complete(State st, int i, Chart chart) {
    for (State s in chart.chart[st.startIndex]) {
      if (!s.isComplete() &&
          s.next()!.equals(Symbol('NT', st.rule.nonTerminal))) {
        var newState = State(s.rule, s.startIndex, s.dot + 1);

        if (!newState.node.children.contains(st.node)) {
          newState.node.addChild(st.node);
        }
        print('Complete $newState');
        chart.chart[i].add(newState);
      }
    }

    if (st.rule.nonTerminal == grammar.startSymbol) {
      // Make sure the root node is connected to its children
      for (State s in chart.chart[st.startIndex]) {
        if (!s.isComplete() && s.rule.nonTerminal == grammar.startSymbol) {
          st.node.addChild(s.node);
        }
      }
    }
  }

  Map<String, dynamic> generateTreeFromChart(Chart chart) {
    List<Map<String, dynamic>> nodes = [];
    List<Map<String, dynamic>> edges = [];
    int nodeId = 1;
    Map<TreeNode, int> nodeMapping = {};

    void traverseTree(TreeNode node, [int? parentId]) {
      if (!nodeMapping.containsKey(node)) {
        int currentId = nodeId++;
        nodes.add({
          'id': currentId,
          'label': node.symbol.value,
        });
        nodeMapping[node] = currentId;

        if (parentId != null) {
          edges.add({'from': parentId, 'to': currentId});
        }
      }

      // Recursively traverse all children
      for (TreeNode child in node.children) {
        traverseTree(child, nodeMapping[node]);
      }
    }

    // Traverse all states in the chart
    for (int i = 0; i < chart.chart.length; i++) {
      for (State state in chart.chart[i]) {
        // Make sure to include complete states and intermediary nodes
        if (state.isComplete() && !allNodes.contains(state.node)) {
          allNodes.add(state.node);
        }
      }
    }

    // Traverse all collected nodes, starting with the root (S)
    for (TreeNode root in allNodes) {
      if (root.symbol.value == grammar.startSymbol) {
        traverseTree(root); // Ensure root is traversed first
      }
    }

    return {
      'nodes': nodes,
      'edges': edges,
    };
  }

  Map<String, dynamic> generateAllTreesJson() {
    List<Map<String, dynamic>> nodes = [];
    List<Map<String, dynamic>> edges = [];
    int nodeId = 1;
    Map<TreeNode, int> nodeMapping = {};

    void traverse(TreeNode node, [int? parentId]) {
      if (!nodeMapping.containsKey(node)) {
        int currentId = nodeId++;
        nodes.add({
          'id': currentId,
          'label': node.symbol.value,
        });
        nodeMapping[node] = currentId;

        if (parentId != null) {
          edges.add({'from': parentId, 'to': currentId});
        }
      }

      for (TreeNode child in node.children) {
        traverse(child, nodeMapping[node]);
      }
    }

    for (TreeNode root in allNodes) {
      traverse(root);
    }

    return {
      'nodes': nodes,
      'edges': edges,
    };
  }

  Map<String, dynamic> generateTreeJson(TreeNode root) {
    List<Map<String, dynamic>> nodes = [];
    List<Map<String, dynamic>> edges = [];
    int nodeId = 1;

    // A map to associate node labels with their unique IDs
    Map<TreeNode, int> nodeMapping = {};

    void traverse(TreeNode node, [int? parentId]) {
      // Assign an ID to the current node
      if (!nodeMapping.containsKey(node)) {
        int currentId = nodeId++;
        nodes.add({
          'id': currentId,
          'label': node.symbol.value,
        });
        nodeMapping[node] = currentId; // Map the node to its ID

        // If there's a parent, add an edge
        if (parentId != null) {
          edges.add({'from': parentId, 'to': currentId});
        }
      }

      // Recursively traverse children
      for (TreeNode child in node.children) {
        traverse(child, nodeMapping[node]);
      }
    }

    traverse(root);

    return {
      'nodes': nodes,
      'edges': edges,
    };
  }
}
