import 'rule.dart';
import 'symbol.dart';

class Grammar {
  List<Rule> rules;
  late String startSymbol;
//   late List<Symbol> terminals;
//   late List<Symbol> nonTerminals;

  // automatically fill out terminal and nonterminal symbols if not given
  Grammar(this.rules,
      [String? start, List<Symbol> t = const [], List<Symbol> nt = const []]) {
    startSymbol = start ?? rules[0].nonTerminal;

    // if (t.isEmpty) {
    //   for (Rule rule in rules) {
    //     for (Symbol sym in rule.production) {
    //       if (sym.type == 'NT' && !terminals.contains(sym)) {
    //         terminals.add(sym);
    //       }
    //     }
    //   }
    // } else {
    //   terminals.addAll(t);
    // }

    // if (nt.isEmpty) {
    //   for (Rule rule in rules) {
    //     for (Symbol sym in rule.production) {
    //       if (sym.type == 'T' && !nonTerminals.contains(sym)) {
    //         nonTerminals.add(sym);
    //       }
    //     }
    //   }
    // } else {
    //   nonTerminals.addAll(nt);
    // }
  }
}
