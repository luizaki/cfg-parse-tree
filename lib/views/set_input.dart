import 'package:flutter/material.dart';
import 'package:cfg_parse_tree/parser/cfg.dart';
import 'package:cfg_parse_tree/views/visualizer.dart';

class SetInput extends StatefulWidget {
  const SetInput({super.key});

  @override
  SetInputState createState() => SetInputState();
}

class SetInputState extends State<SetInput> {
  // initial rules
  List<Rule> rules = [
    Rule('S', [T('ε')])
  ];
  List<TextEditingController> nonTerminalControllers = [];
  List<List<TextEditingController>> productionControllersList = [];
  TextEditingController inputStringController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nonTerminalControllers
        .add(TextEditingController(text: rules[0].nonTerminal));
    productionControllersList
        .add([TextEditingController(text: rules[0].production[0].value)]);
  }

  void addRule() {
    setState(() {
      rules.add(Rule('', []));
      nonTerminalControllers.add(TextEditingController());
      productionControllersList
          .add([TextEditingController(text: 'ε')]); // default value
    });
  }

  void deleteRule(int index) {
    // prevent the first rule being deleted
    if (index > 0) {
      setState(() {
        rules.removeAt(index);
        nonTerminalControllers.removeAt(index);
        productionControllersList.removeAt(index);
      });
    }
  }

  void addProduction(int index) {
    setState(() {
      productionControllersList[index].add(TextEditingController(text: 'ε'));
    });
  }

  void resetRules() {
    setState(() {
      rules = [
        Rule('S', [T('ε')])
      ];
      nonTerminalControllers.clear();
      productionControllersList.clear();

      nonTerminalControllers
          .add(TextEditingController(text: rules[0].nonTerminal));
      productionControllersList
          .add([TextEditingController(text: rules[0].production[0].value)]);
    });
    inputStringController.clear();
  }

  List<Rule> convertToRules() {
    setState(() {
      rules = [];

      for (int i = 0; i < nonTerminalControllers.length; i++) {
        String nonTerminal = nonTerminalControllers[i].text;

        if (productionControllersList[i].isNotEmpty) {
          // add to production depending if its epsilon, terminal or nonterminal
          // TODO: find a better way to determine such, as of now it only verifies by uppercase (nt) or not
          for (TextEditingController productionController
              in productionControllersList[i]) {
            String productionString = productionController.text.trim();
            List<Symbol> productionSymbols = [];

            if (productionString.isEmpty) continue;

            if (productionString == 'ε') {
              productionSymbols.add(T('ε'));
            } else {
              for (int j = 0; j < productionString.length; j++) {
                String c = productionString[j];

                if (c.isNotEmpty && c.toUpperCase() == c[0] && c.length == 1) {
                  productionSymbols.add(NT(c));
                } else if (c.isNotEmpty) {
                  productionSymbols.add(T(c));
                }
              }
            }

            if (productionSymbols.isNotEmpty) {
              rules.add(Rule(nonTerminal, productionSymbols));
            }
          }
        }
      }
    });
    return rules;
  }

  void generateTree() {
    List<Rule> rules = convertToRules();
    String inputString = inputStringController.text.trim();

    // immediately show alert if input string is empty
    if (inputString.isEmpty) {
      showAlert(context, 'Invalid Input!!!', 'Input string cannot be empty.');
      return;
    } else {
      // attempt to parse
      Parser parser = Parser(Grammar(rules));
      var result = parser.parse(inputString);

      if (result is Map<String, dynamic>) {
        // move to visualiser if a json was generated
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TreeView(cfg: result),
          ),
        );
      } else {
        // otherwise just show invalid and stay to the current screen
        showAlert(context, 'Invalid Input!!!',
            'Input string is not valid in the given grammar.');
      }
    }
  }

  void showAlert(BuildContext context, String title, String msg) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(title: Text(title), content: Text(msg), actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            )
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('CFG Parse Tree Generator'),
        ),
        body: Column(children: [
          Expanded(
            child: ListView.builder(
              itemCount: rules.length,
              itemBuilder: (content, index) {
                if (index < nonTerminalControllers.length &&
                    index < productionControllersList.length) {
                  return RuleInput(
                    nonTerminalController: nonTerminalControllers[index],
                    productionControllers: productionControllersList[index],
                    onAddProduction: () => addProduction(index),
                    onDelete: () => deleteRule(index),
                    isFirstRule: index == 0,
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: addRule,
            child: const Text('Add Rule'),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: resetRules,
            child: const Text('Reset'),
          ),
          const SizedBox(height: 20.0),
          TextField(
              controller: inputStringController,
              decoration: const InputDecoration(
                labelText: 'Input String',
                hintText: 'Enter string to parse',
              )),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: generateTree,
            child: const Text('Generate'),
          ),
        ]));
  }
}

class RuleInput extends StatefulWidget {
  final TextEditingController nonTerminalController;
  final List<TextEditingController> productionControllers;
  final VoidCallback onAddProduction;
  final VoidCallback onDelete;
  final bool isFirstRule;

  RuleInput({
    required this.nonTerminalController,
    required this.productionControllers,
    required this.onAddProduction,
    required this.onDelete,
    required this.isFirstRule,
  });

  @override
  _RuleInputState createState() => _RuleInputState();
}

class _RuleInputState extends State<RuleInput> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Nonterminal',
                hintText: 'e.g. S',
              ),
              controller: widget.nonTerminalController,
            ),
          ),
          const SizedBox(width: 10),
          const Text('→'),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                for (var controller in widget.productionControllers)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Production',
                        hintText: 'e.g. aS | b',
                      ),
                      controller: controller,
                    ),
                  ),
                ElevatedButton(
                  onPressed: widget.onAddProduction,
                  child: const Text('Add Production'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (!widget.isFirstRule)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: widget.onDelete,
              tooltip: 'Delete this rule',
            ),
        ],
      ),
    );
  }
}
