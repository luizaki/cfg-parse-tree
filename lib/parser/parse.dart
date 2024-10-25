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
      if (rule.nonTerminal == st.next()!.value) {
        var newState = State(rule, i, 0);
        chart.chart[i].add(newState);

        // Attach the predicted non-terminal node to the current state node
        TreeNode nonTerminalNode = TreeNode(Symbol('NT', rule.nonTerminal));
        st.node.addChild(nonTerminalNode); // Link to parent
        newState.node = nonTerminalNode; // Set new state node for tree
      }
    }
  }

  void scan(State st, int i, String input, Chart chart) {
    if (st.startIndex + st.dot < input.length) {
      if (st.next()!.value == input[st.startIndex + st.dot]) {
        var newState = State(st.rule, st.startIndex, st.dot + 1);

        // Create a TreeNode for the scanned terminal symbol
        TreeNode terminalNode = TreeNode(Symbol('T', input[st.startIndex + st.dot]));
        st.node.addChild(terminalNode); // Link terminal to parent
        newState.node = st.node; // Pass the same parent node to next state

        chart.chart[i + 1].add(newState);
      }
    }
  }

  void complete(State st, int i, Chart chart) {
    for (State s in chart.chart[st.startIndex]) {
      if (!s.isComplete() && s.next()!.equals(Symbol('NT', st.rule.nonTerminal))) {
        var newState = State(s.rule, s.startIndex, s.dot + 1);

        // Attach completed subtree to parent
        s.node.addChild(st.node); // Connect child to parent's tree
        newState.node = s.node; // Set parent node for the new state

        chart.chart[i].add(newState);
      }
    }
  }



  Map<String, dynamic> generateTreeJson(TreeNode root) {
  List<Map<String, dynamic>> nodes = [];
  List<Map<String, dynamic>> edges = [];
  int nodeId = 1;

  // Map to assign each TreeNode a unique ID
  Map<TreeNode, int> nodeMapping = {};

    // Recursive function to add nodes and edges for the JSON structure
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

      int currentNodeId = nodeMapping[node]!;
      for (TreeNode child in node.children) {
        traverse(child, currentNodeId);
      }
    }

    traverse(root); // Start traversing from root
    return {
      'nodes': nodes,
      'edges': edges,
    };
  }
}
