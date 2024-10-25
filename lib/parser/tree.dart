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

  @override
  String toString() {
    return symbol.value;
  }
}
