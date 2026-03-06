import 'package:equiny/core/conversation/dtos/entities/message_dto.dart';
import 'package:equiny/core/conversation/dtos/structures/chat_date_section_dto.dart';

import 'message_faker.dart';

class ChatDateSectionFaker {
  static ChatDateSectionDto fakeDto({
    DateTime? date,
    String? label,
    List<MessageDto>? messages,
  }) {
    final resolvedDate = date ?? DateTime(2026, 1, 1);
    return ChatDateSectionDto(
      date: resolvedDate,
      label: label ?? 'HOJE',
      messages: messages ?? <MessageDto>[MessageFaker.fakeDto()],
    );
  }

  static List<ChatDateSectionDto> fakeManyDto({int length = 2}) {
    return List<ChatDateSectionDto>.generate(
      length,
      (int index) => fakeDto(
        date: DateTime(2026, 1, index + 1),
        label: '0${index + 1} DE JAN',
        messages: <MessageDto>[
          MessageFaker.fakeDto(
            id: 'msg-section-$index',
            sentAt: DateTime(2026, 1, index + 1, 10, 30),
          ),
        ],
      ),
    );
  }
}
