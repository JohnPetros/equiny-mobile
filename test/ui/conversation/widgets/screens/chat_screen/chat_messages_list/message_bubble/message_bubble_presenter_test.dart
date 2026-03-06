import 'package:equiny/ui/conversation/widgets/screens/chat_screen/chat_messages_list/message_bubble/message_bubble_presenter.dart';
import 'package:equiny/ui/shared/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MessageBubblePresenter presenter;

  setUp(() {
    presenter = MessageBubblePresenter();
  });

  group('MessageBubblePresenter', () {
    test('should return primary color for own message background', () {
      expect(presenter.bubbleBackground(true), AppThemeColors.primary);
    });

    test('should return surface color for other message background', () {
      expect(presenter.bubbleBackground(false), AppThemeColors.surface);
    });

    test('should return border color for own message text', () {
      expect(presenter.textColor(true), AppThemeColors.border);
    });

    test('should return textSecondary color for other message text', () {
      expect(presenter.textColor(false), AppThemeColors.textSecondary);
    });

    test('should identify image kind', () {
      expect(presenter.isImage('image'), isTrue);
      expect(presenter.isImage('pdf'), isFalse);
    });

    test('should identify document kinds', () {
      expect(presenter.isDocument('pdf'), isTrue);
      expect(presenter.isDocument('docx'), isTrue);
      expect(presenter.isDocument('txt'), isTrue);
      expect(presenter.isDocument('document'), isTrue);
      expect(presenter.isDocument('image'), isFalse);
    });

    test('should return correct icon data for different kinds', () {
      expect(presenter.attachmentIconData('image'), isNotNull);
      expect(presenter.attachmentIconData('pdf'), isNotNull);
      expect(presenter.attachmentIconData('unknown'), isNotNull);
    });
  });
}
