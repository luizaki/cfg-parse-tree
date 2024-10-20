class Symbol {
  String type;
  String value;

  Symbol(this.type, this.value);

  bool equals(Symbol other) {
    return other.type == type && other.value == value;
  }

  @override
  String toString() {
    return value.toString();
  }
}

Symbol NT(String value) => Symbol('NT', value);
Symbol T(String value) => Symbol('T', value);
