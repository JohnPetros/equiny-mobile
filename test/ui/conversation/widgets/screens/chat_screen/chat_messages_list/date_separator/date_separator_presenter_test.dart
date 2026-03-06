import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/date_separator/date_separator_presenter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateSeparatorPresenter presenter;

  setUp(() {
    presenter = DateSeparatorPresenter();
  });

  group('DateSeparatorPresenter', () {
    test('should return label in uppercase', () {
      expect(presenter.formatLabel('hoje'), 'HOJE');
    });

    test('should return already uppercase label unchanged', () {
      expect(presenter.formatLabel('ONTEM'), 'ONTEM');
    });

    test('should handle mixed case label', () {
      expect(presenter.formatLabel('01 De Jan'), '01 DE JAN');
    });

    test('should handle empty label', () {
      expect(presenter.formatLabel(''), '');
    });
  });
}
