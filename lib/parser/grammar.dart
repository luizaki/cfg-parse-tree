import 'rule.dart';
import 'symbol.dart';

class Grammar {
  List<Rule> rules;
  late String startSymbol;

  // automatically fill out terminal and nonterminal symbols if not given
  Grammar(this.rules,
      [String? start, List<Symbol> t = const [], List<Symbol> nt = const []]) {
    startSymbol = start ?? rules[0].nonTerminal;
  }
}
