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
    var startState = State(grammar.rules[0], 0, 0);
    startState.node = TreeNode(NT(grammar.rules[0].nonTerminal));
    chart[0].add(startState);
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

      // debugging output
      print("Chart at index $i: ${chart.chart[i]}");
      i++;
    }

    // check if input is accepted by looking for completed start states
    for (State state in chart.chart[input.length]) {
      if (state.rule.nonTerminal == grammar.startSymbol &&
          state.isComplete() &&
          state.startIndex == 0) {
        print(state);
        var jsonTree = generateTreeJson(state.node);
        print(jsonTree);
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
        newState.node = TreeNode(NT(rule.nonTerminal)); // Create a node for non-terminal

        if (!chart.chart[i].any((s) => s.equals(newState))) {
          chart.chart[i].add(newState);
          st.node.addChild(newState.node); // Link new non-terminal to parent
        }

        // Handle nullable (epsilon) rules
        if (rule.isNullable()) {
          // Move dot for nullable production
          var epsilonState = State(st.rule, st.startIndex, st.dot + 1);
          if (!chart.chart[i].any((s) => s.equals(epsilonState))) {
            chart.chart[i].add(epsilonState);

            // Create epsilon node under the new state for nullable production
            TreeNode epsilonNode = TreeNode(Symbol('T', 'ε'));
            newState.node.addChild(epsilonNode); // Attach epsilon to `A` (not `S`)
            epsilonState.node = st.node; // Complete the link back to parent state node
          }
        }
      }
    }
  }

  // move dot if state's right hand matches input
  void scan(State st, int i, String input, Chart chart) {
    if (st.startIndex + st.dot < input.length) {
      if (st.next()!.value == input[st.startIndex + st.dot]) {
        var newState = State(st.rule, st.startIndex, st.dot + 1);

        // creating a node for the terminal
        TreeNode terminalNode =
            TreeNode(Symbol('T', input[st.startIndex + st.dot]));
        st.node.addChild(terminalNode);
        newState.node = st.node;

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
        newState.node = s.node; // Inherit node reference

        // Link completed subtree to parent in the tree
        s.node.addChild(st.node);
        chart.chart[i].add(newState);
      }
    }
  }

  Map<String, dynamic> generateTreeJson(TreeNode root) {
    List<Map<String, dynamic>> nodes = [];
    List<Map<String, dynamic>> edges = [];
    int nodeId = 1;

    // assign ids to nodes
    Map<TreeNode, int> nodeMapping = {};

    // recursive function to add nodes and edges for the JSON structure
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

      // traverse similarly for each child
      for (TreeNode child in node.children) {
        traverse(child, currentNodeId);
      }
    }

    // begin recursion with the root
    traverse(root);

    return {
      'nodes': nodes,
      'edges': edges,
    };
  }
}
