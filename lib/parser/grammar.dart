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

class Rule {
  String nonTerminal;
  List<Symbol> production;
  late Symbol nt = Symbol('NT', nonTerminal);

  Rule(this.nonTerminal, this.production);

  bool equals(Rule other) {
    if (other.nonTerminal != nonTerminal) return false;
    if (other.production.length != production.length) return false;

    for (int i = 0; i < other.production.length; ++i) {
      if (!other.production[i].equals(production[i])) return false;
    }
    return true;
  }

  bool isNullable() {
    for (Symbol s in production) {
      if (s.value == 'ε') return true;
    }
    return false;
  }

  @override
  String toString() {
    return '$nonTerminal -> ${production.join('')}';
  }
}
