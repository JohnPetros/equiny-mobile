abstract class Event<Payload> {
  final String _name;
  final Payload payload;

  Event({required String name, required this.payload}) : _name = name;

  String getName() {
    return _name;
  }
}
