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

  bool isNullable() => production.contains(T('ε'));

  @override
  String toString() {
    return '$nonTerminal -> ${production.join('')}';
  }

  String repr() {
    String out = 'Rule(\'$nonTerminal\', [';
    for (int i = 0; i < production.length; ++i) {
      if (i > 0) out += ', ';
      out += '${production[i].type}(\'${production[i].value}\')';
    }
    out += '])';
    return out;
  }
}
