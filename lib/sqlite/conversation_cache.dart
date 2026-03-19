import 'dart:convert';
import 'package:fanari_v2/model/conversation.dart';
import 'package:fanari_v2/model/text.dart';
import 'package:fanari_v2/sqlite/sqlite.dart';

/// Local cache layer for conversations and text messages.
/// Works directly with model classes — no raw maps at the boundary.
class ConversationCache {
  static final ConversationCache instance = ConversationCache._();
  ConversationCache._();

  final _db = Sqlite.instance;

  // ── Conversations ──────────────────────────────────────────────────────────

  /// Save a list of conversations to local cache.
  Future<void> save_conversations(List<ConversationModel> conversations) async {
    final db = await _db.database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final conv in conversations) {
      batch.rawInsert(
        '''
        INSERT OR REPLACE INTO conversation
        (uuid, type, last_message_at, is_favorite, is_muted, unread_count, single_metadata, group_metadata, last_text, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          conv.core.uuid,
          conv.core.type == ConversationType.Group ? 'Group' : 'Single',
          conv.core.last_message_at,
          conv.common_metadata.favorite ? 1 : 0,
          conv.common_metadata.muted ? 1 : 0,
          conv.unread_count,
          conv.single_metadata != null
              ? jsonEncode(conv.single_metadata!.toJson())
              : null,
          conv.group_metadata != null
              ? jsonEncode(conv.group_metadata!.toJson())
              : null,
          conv.last_text != null ? jsonEncode(conv.last_text!.toJson()) : null,
          now,
        ],
      );
    }

    await batch.commit(noResult: true);
  }

  /// Load all cached conversations, ordered by last_message_at descending.
  /// Returns JSON-compatible maps ready for ConversationModel.fromJson().
  Future<List<Map<String, dynamic>>> get_conversations() async {
    final rows = await _db.query(
      table: 'conversation',
      orderBy: 'last_message_at DESC',
    );

    return rows.map((row) {
      return {
        'core': {
          'uuid': row['uuid'],
          'type': row['type'],
          'last_message_at': row['last_message_at'],
        },
        'common_metadata': {
          'is_favorite': row['is_favorite'] == 1,
          'is_muted': row['is_muted'] == 1,
        },
        'single_metadata': row['single_metadata'] != null
            ? jsonDecode(row['single_metadata'] as String)
            : null,
        'group_metadata': row['group_metadata'] != null
            ? jsonDecode(row['group_metadata'] as String)
            : null,
        'last_text': row['last_text'] != null
            ? jsonDecode(row['last_text'] as String)
            : null,
        'unread_count': row['unread_count'],
      };
    }).toList();
  }

  /// Update a single conversation's metadata in cache.
  Future<void> update_conversation({
    required String uuid,
    bool? is_favorite,
    bool? is_muted,
    int? unread_count,
    int? last_message_at,
    TextModel? last_text,
  }) async {
    final data = <String, dynamic>{
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };

    if (is_favorite != null) data['is_favorite'] = is_favorite ? 1 : 0;
    if (is_muted != null) data['is_muted'] = is_muted ? 1 : 0;
    if (unread_count != null) data['unread_count'] = unread_count;
    if (last_message_at != null) data['last_message_at'] = last_message_at;
    if (last_text != null) {
      data['last_text'] = jsonEncode(last_text.toJson());
    }

    await _db.update(
      table: 'conversation',
      data: data,
      where: 'uuid = ?',
      whereArgs: [uuid],
    );
  }

  // ── Text messages ──────────────────────────────────────────────────────────

  /// Save a list of text messages to local cache.
  Future<void> save_texts(List<TextModel> texts) async {
    final db = await _db.database;
    final batch = db.batch();

    for (final text in texts) {
      if (text.uuid.startsWith('temp_')) continue;

      batch.rawInsert(
        '''
        INSERT OR REPLACE INTO text_message
        (uuid, conversation_id, owner, type, text, images, video, audio, attachment, seen_by, created_at, my_text)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          text.uuid,
          text.conversation_id,
          text.owner,
          text.type.name,
          text.text,
          text.images != null
              ? jsonEncode(text.images!.map((img) => img.toJson()).toList())
              : null,
          text.video != null ? jsonEncode(text.video!.toJson()) : null,
          text.audio != null ? jsonEncode(text.audio!.toJson()) : null,
          text.attachment != null
              ? jsonEncode(text.attachment!.toJson())
              : null,
          jsonEncode(text.seen_by),
          text.created_at,
          text.my_text ? 1 : 0,
        ],
      );
    }

    await batch.commit(noResult: true);
  }

  /// Load cached texts for a conversation, paginated.
  /// Returns JSON-compatible maps ready for TextModel.fromJson().
  Future<List<Map<String, dynamic>>> get_texts({
    required String conversation_id,
    required int limit,
    required int offset,
  }) async {
    final rows = await _db.query(
      table: 'text_message',
      where: 'conversation_id = ?',
      whereArgs: [conversation_id],
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );

    return rows.map((row) {
      return {
        'uuid': row['uuid'],
        'conversation_id': row['conversation_id'],
        'owner': row['owner'],
        'type': row['type'],
        'text': row['text'],
        'images': row['images'] != null
            ? jsonDecode(row['images'] as String)
            : null,
        'video': row['video'] != null
            ? jsonDecode(row['video'] as String)
            : null,
        'audio': row['audio'] != null
            ? jsonDecode(row['audio'] as String)
            : null,
        'attachment': row['attachment'] != null
            ? jsonDecode(row['attachment'] as String)
            : null,
        'seen_by': jsonDecode(row['seen_by'] as String),
        'created_at': row['created_at'],
      };
    }).toList();
  }

  /// Save a single text message (e.g. from socket).
  Future<void> save_text(TextModel text) async {
    await save_texts([text]);
  }

  /// Update seen_by for specific text messages.
  Future<void> update_seen_by({
    required List<String> text_ids,
    required String user_id,
  }) async {
    final db = await _db.database;

    for (final id in text_ids) {
      final rows = await db.query(
        'text_message',
        columns: ['seen_by'],
        where: 'uuid = ?',
        whereArgs: [id],
      );

      if (rows.isEmpty) continue;

      final seen_by = List<String>.from(
        jsonDecode(rows.first['seen_by'] as String),
      );

      if (seen_by.contains(user_id)) continue;

      seen_by.add(user_id);
      await db.update(
        'text_message',
        {'seen_by': jsonEncode(seen_by)},
        where: 'uuid = ?',
        whereArgs: [id],
      );
    }
  }

  /// Delete temp messages for a conversation.
  Future<void> delete_temp_texts(String conversation_id) async {
    await _db.delete(
      table: 'text_message',
      where: 'conversation_id = ? AND uuid LIKE ?',
      whereArgs: [conversation_id, 'temp_%'],
    );
  }

  /// Clear all cached data (for logout).
  Future<void> clear_all() async {
    final db = await _db.database;
    await db.delete('conversation');
    await db.delete('text_message');
  }
}
