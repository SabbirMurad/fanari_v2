enum CallType { audio, video }

enum CallSignalType {
  // 1-to-1
  call_request,
  call_accept,
  call_reject,
  call_end,
  // Group
  call_start,
  call_join,
  call_leave,
  // WebRTC (both 1-1 and group)
  offer,
  answer,
  ice_candidate,
  // In-call controls
  video_toggle,
  audio_toggle,
  // Server → client only
  call_participants,
  peer_offline,
  unknown,
}

class CallSignal {
  final CallSignalType type;
  final String from;
  final String? to;
  final String? room_id;
  final String? sdp;
  final Map<String, dynamic>? candidate;
  final CallType? call_type;
  final bool? enabled;
  final bool? muted;
  final List<String>? participants;

  const CallSignal({
    required this.type,
    required this.from,
    this.to,
    this.room_id,
    this.sdp,
    this.candidate,
    this.call_type,
    this.enabled,
    this.muted,
    this.participants,
  });

  factory CallSignal.from_json(Map<String, dynamic> json) {
    final type = switch (json['type'] as String? ?? '') {
      'call_request'     => CallSignalType.call_request,
      'call_accept'      => CallSignalType.call_accept,
      'call_reject'      => CallSignalType.call_reject,
      'call_end'         => CallSignalType.call_end,
      'call_start'       => CallSignalType.call_start,
      'call_join'        => CallSignalType.call_join,
      'call_leave'       => CallSignalType.call_leave,
      'offer'            => CallSignalType.offer,
      'answer'           => CallSignalType.answer,
      'ice_candidate'    => CallSignalType.ice_candidate,
      'video_toggle'     => CallSignalType.video_toggle,
      'audio_toggle'     => CallSignalType.audio_toggle,
      'call_participants'=> CallSignalType.call_participants,
      'peer_offline'     => CallSignalType.peer_offline,
      _                  => CallSignalType.unknown,
    };

    return CallSignal(
      type: type,
      from: json['from'] as String? ?? '',
      to: json['to'] as String?,
      room_id: json['room_id'] as String?,
      sdp: json['sdp'] as String?,
      candidate: json['candidate'] as Map<String, dynamic>?,
      call_type: json['call_type'] == 'Video' ? CallType.video : CallType.audio,
      enabled: json['enabled'] as bool?,
      muted: json['muted'] as bool?,
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }
}
