import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import '../utils/button_values.dart';

class CalculatorScreen extends StatefulWidget {
  final Function(String) onHistoryAdded;

  const CalculatorScreen({super.key, required this.onHistoryAdded});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = "";
  String result = "0";

  void onButtonPressed(String value) {
    setState(() {
      if (value == Btn.clr) {
        input = "";
        result = "0";
      } else if (value == Btn.del) {
        if (input.isNotEmpty) {
          input = input.substring(0, input.length - 1);
        }
      } else if (value == Btn.calculate) {
        if (input.isNotEmpty) {
          calculateResult();
        }
      } else {
        if (input.isNotEmpty &&
            ["+", "-", "*", "/"].contains(value) &&
            ["+", "-", "*", "/"].contains(input[input.length - 1])) {
          return;
        }
        input += value;
      }
    });
  }

  void calculateResult() {
    try {
      if (input.isEmpty) return;

      if (["+", "-", "*", "/"].contains(input[input.length - 1])) {
        input = input.substring(0, input.length - 1);
      }

      Parser p = Parser();
      Expression exp = p.parse(input);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);
      String hasil = eval.toString();

      // Simpan ekspresi lengkap ke history
      widget.onHistoryAdded("$input = $hasil");

      setState(() {
        result = hasil;
        input = hasil;
      });
    } catch (e) {
      setState(() {
        result = "Error";
      });
    }
  }

  Widget buildButton(String value) {
    return ElevatedButton(
      onPressed: () => onButtonPressed(value),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: getButtonColor(value),
      ),
      child: Center(
        child: Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Color getButtonColor(String value) {
    if (value == Btn.clr || value == Btn.del) return Colors.redAccent;
    if (value == Btn.calculate) return Colors.green;
    if (["+", "-", "*", "/"].contains(value)) return Colors.orange;
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calculator")),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomRight,
                constraints: const BoxConstraints(minHeight: 80, maxHeight: 100),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    input.isEmpty ? result : input,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: Btn.buttonValues.length,
                  itemBuilder: (context, index) {
                    return buildButton(Btn.buttonValues[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
