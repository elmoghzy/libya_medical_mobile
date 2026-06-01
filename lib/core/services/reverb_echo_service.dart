import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class ReverbEchoService {
  ReverbEchoService({
    this.host = 'tobago-deposit-weekend-translate.trycloudflare.com',
    this.port = 443,
    this.wsPort = 443,
    this.forceTLS = true,
    this.disableStats = true,
    this.key = 'your_reverb_app_key',
    this.cluster = 'mt1',
  });

  final String host;
  final int port;
  final int wsPort;
  final bool forceTLS;
  final bool disableStats;
  final String key;
  final String cluster;

  Echo? _echo;
  PusherChannelsFlutter? _pusher;
  String? _activeChannelName;

  Future<void> initialize() async {
    if (_echo != null) {
      return;
    }

    _pusher = PusherChannelsFlutter.getInstance();
    await _pusher!.init(
      apiKey: key,
      cluster: cluster,
      useTLS: forceTLS,
    );
    await _pusher!.connect();

    _echo = Echo(
      broadcaster: EchoBroadcasterType.Pusher,
      client: _pusher,
    );
  }

  void listenToQueueChannel({
    required int doctorId,
    required void Function(dynamic data) onEvent,
  }) {
    if (_echo == null) {
      return;
    }

    final channelName = 'doctor.$doctorId.queue';
    _activeChannelName = channelName;
    _echo!
        .channel(channelName)
        .listen('App\\Events\\QueueStatusUpdated', onEvent);
  }

  void leaveChannel() {
    if (_echo == null || _activeChannelName == null) {
      return;
    }

    _echo!.leave(_activeChannelName!);
    _activeChannelName = null;
  }

  Future<void> disconnect() async {
    leaveChannel();
    if (_pusher != null) {
      await _pusher!.disconnect();
    }
    _echo = null;
  }
}
