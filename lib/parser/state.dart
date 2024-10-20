import 'rule.dart';
import 'symbol.dart';
import 'tree.dart';

class State {
  Rule rule;
  int startIndex;
  int dot;
  TreeNode? node;

  State(this.rule, this.startIndex, this.dot, {this.node});

  Symbol? next() {
    return dot < rule.production.length ? rule.production[dot] : null;
  }

  bool isComplete() => dot >= rule.production.length;

  bool equals(State other) {
    return other.rule == rule &&
        other.startIndex == startIndex &&
        other.dot == dot;
  }

  @override
  String toString() {
    List<String> productionWithDot = [];
    for (int i = 0; i < rule.production.length; i++) {
      if (i == dot) {
        productionWithDot.add('•');
      }
      productionWithDot.add(rule.production[i].toString());
    }

    if (dot == rule.production.length) {
      productionWithDot.add('•');
    }

    return '${rule.nonTerminal} -> ${productionWithDot.join('')}';
  }
}
