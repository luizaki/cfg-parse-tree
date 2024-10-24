import 'symbol.dart';

class TreeNode {
  Symbol symbol;
  List<TreeNode> children;

  TreeNode(
    this.symbol,
  ) : children = [];

  TreeNode.hadChild(this.symbol, this.children);

  void addChild(TreeNode child) {
    children.add(child);
  }

  void printTree([int level = 0]) {
    // print the current node with indentation
    print('${' ' * level}-$symbol');
    for (var child in children) {
      child.printTree(level + 2); // Increase indentation for child nodes
    }
  }

  @override
  String toString() {
    return symbol.value;
  }
}
