import 'grammar.dart';
import 'state.dart';
import 'rule.dart';
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

  Parser(this.grammar);

  bool parse(String input) {
    Chart chart = Chart(grammar, input);

    // go over the chart
    var i = 0;
    while (i < chart.length()) {
      var j = 0;

      while (j < chart.chart[i].length) {
        State state = chart.chart[i][j];
        print('Checking $state');
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
    return chart.chart[input.length].any((state) =>
        state.rule.nonTerminal == grammar.startSymbol &&
        state.isComplete() &&
        state.startIndex == 0);
  }

  // add new states
  void predict(State st, int i, Chart chart) {
    for (Rule rule in grammar.rules) {
      // if rule's left hand (nt) matches the next state's left hand (nt), add to chart
      if (rule.nonTerminal == st.next()!.value) {
        if (rule.isNullable()) {
          var epsilonState = State(st.rule, st.startIndex, st.dot + 1);
          chart.chart[i].add(epsilonState);
        } else {
          var newState = State(rule, i, 0);
          chart.chart[i].add(newState);
        }
      }
    }
  }

// move dot if state's right hand matches input
  void scan(State st, int i, String input, Chart chart) {
    if (st.startIndex + st.dot < input.length) {
      if (st.next()!.value == input[st.startIndex + st.dot]) {
        var newState = State(st.rule, st.startIndex, st.dot + 1);
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
        chart.chart[i].add(newState);
      }
    }
  }
}

void main() {
  List<Rule> rules = [
    Rule('S', [NT('A'), NT('B')]),
    Rule('A', [T('a'), NT('B'), T('c')]),
    Rule('A', [T('a'), NT('A')]),
    Rule('B', [T('b'), NT('C')]),
    Rule('B', [NT('D')]),
    Rule('C', [T('c')]),
    Rule('D', [T('d')]),
  ];

  Parser grammar = Parser(Grammar(rules));

  bool parse = grammar.parse('adcd');
  if (parse) {
    print('accepted');
  } else
    print('rejected');
}
