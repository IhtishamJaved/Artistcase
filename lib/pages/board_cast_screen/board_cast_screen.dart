import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import '../../constant/appId.dart';
import '../../constant/constant.dart';
import '../../constant/sizeconfig.dart';
import '../../roots/bottom_navigation_bar.dart';
import '../../services/firestoremethod.dart';
import '../../widgets/custom_button.dart';

class BroadcastScreen extends StatefulWidget {
  final bool isBroadcaster;
  final String channelId;
  final String uid;
  final String username;
  const BroadcastScreen({
    Key key,
    @required this.isBroadcaster,
    @required this.channelId,
    @required this.uid,
    @required this.username,
  }) : super(key: key);

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  RtcEngine engine;
  List<int> remoteUid = [];
  bool switchCamera = true;
  bool isMuted = false;
  bool isScreenSharing = false;

  @override
  void initState() {
    super.initState();

    _initEngine();
  }

  void _initEngine() async {
    engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    _addListeners();

    await engine.enableVideo();
    await engine.startPreview();
    await engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadcaster) {
      engine.setClientRole(ClientRole.Broadcaster);
    } else {
      engine.setClientRole(ClientRole.Audience);
    }
    _joinChannel();
  }

  String baseUrl = "https://socialssapps.herokuapp.com";

  String token;

  Future<void> getToken() async {
    print(firebaseAuth.currentUser.uid);
    final res = await http.get(
      Uri.parse(baseUrl +
          '/rtc/' +
          widget.channelId +
          '/publisher/userAccount/' +
          firebaseAuth.currentUser.uid +
          '/'),
    );

    if (res.statusCode == 200) {
      setState(() {
        token = res.body;
        token = jsonDecode(token)['rtcToken'];
        print("Hello eowgnbbdbzdnz");
        print(token);
      });
    } else {
      debugPrint('Failed to fetch the token');

      print("gjzhghgashshrsrhthsyhzhzddhh");
    }
  }

  void _addListeners() {
    engine.setEventHandler(
        RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
      debugPrint('joinChannelSuccess $channel $uid $elapsed');
    }, userJoined: (uid, elapsed) {
      debugPrint('userJoined $uid $elapsed');
      setState(() {
        remoteUid.add(uid);
      });
    }, userOffline: (uid, reason) {
      debugPrint('userOffline $uid $reason');
      setState(() {
        remoteUid.removeWhere((element) => element == uid);
      });
    }, leaveChannel: (stats) {
      debugPrint('leaveChannel $stats');
      setState(() {
        remoteUid.clear();
      });
    }, tokenPrivilegeWillExpire: (token) async {
      await getToken();
      await engine.renewToken(token);
    }));
  }

  void _joinChannel() async {
    await getToken();

    try {
      if (token != null) {
        if (defaultTargetPlatform == TargetPlatform.android) {
          await [Permission.microphone, Permission.camera].request();
        }
        await engine.joinChannelWithUserAccount(
          token,
          widget.channelId,
          firebaseAuth.currentUser.uid,
        );
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _switchCamera() {
    engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      debugPrint('switchCamera $err');
    });
  }

  void onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await engine.muteLocalAudioStream(isMuted);
  }

  // ignore: unused_element
  _startScreenShare() async {
    final helper = await engine.getScreenShareHelper(
        appGroup: kIsWeb || Platform.isWindows ? null : 'io.agora');
    await helper.disableAudio();
    await helper.enableVideo();
    await helper.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await helper.setClientRole(ClientRole.Broadcaster);
    var windowId = 0;
    var random = Random();
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isAndroid)) {
      final windows = engine.enumerateWindows();
      if (windows.isNotEmpty) {
        final index = random.nextInt(windows.length - 1);
        debugPrint('Screensharing window with index $index');
        windowId = windows[index].id;
      }
    }
    await helper.startScreenCaptureByWindowId(windowId);
    setState(() {
      isScreenSharing = true;
    });
    await helper.joinChannelWithUserAccount(
      token,
      widget.channelId,
      firebaseAuth.currentUser.uid,
    );
  }

  // ignore: unused_element
  _stopScreenShare() async {
    final helper = await engine.getScreenShareHelper();
    await helper.destroy().then((value) {
      setState(() {
        isScreenSharing = false;
      });
    }).catchError((err) {
      debugPrint('StopScreenShare $err');
    });
  }

  _leaveChannel() async {
    await engine.leaveChannel();
    if ('${widget.uid}${widget.username}' == widget.channelId) {
      await FirestoreMethods().endLiveStream(widget.channelId);
    } else {
      await FirestoreMethods().updateViewCount(widget.channelId, false);
    }
    Get.offAll(() => BottomNavigationTabBar());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel();
        return Future.value(true);
      },
      child: Scaffold(
        bottomNavigationBar: widget.isBroadcaster
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: CustomButton(
                  text: 'End Stream',
                  onTap: _leaveChannel,
                ),
              )
            : null,
        body: Padding(
          padding: const EdgeInsets.all(0),
          child: Stack(
            children: [
              _renderVideo('${widget.uid}${widget.username}', isScreenSharing),
              if ('${widget.uid}${widget.username}' == widget.channelId)
                Positioned(
                  bottom: 2 * SizeConfig.heightMultiplier,
                  child: InkWell(
                    onTap: _switchCamera,
                    child: Icon(
                      Icons.camera,
                      color: Colors.red,
                      size: 5 * SizeConfig.heightMultiplier,
                    ),
                  ),
                ),
              Positioned(
                bottom: 10 * SizeConfig.heightMultiplier,
                child: InkWell(
                  onTap: onToggleMute,
                  child: isMuted
                      ? Icon(
                          Icons.mic_off,
                          color: Colors.red,
                        )
                      : Icon(Icons.mic),
                ),
              ),
            ],
          ),
          // Expanded(
          //   child: Chat(
          //     channelId: widget.channelId,
          //   ),
          // ),

          //  Row(
          //   children: [
          //     Expanded(
          //       child: Column(
          //         children: [
          //           _renderVideo(
          //               '${widget.uid}${widget.username}', isScreenSharing),
          //           if ('${widget.uid}${widget.username}' == widget.channelId)
          //             Column(
          //               mainAxisSize: MainAxisSize.min,
          //               mainAxisAlignment: MainAxisAlignment.start,
          //               children: [
          //                 InkWell(
          //                   onTap: _switchCamera,
          //                   child: const Text('Switch Camera'),
          //                 ),
          //                 InkWell(
          //                   onTap: onToggleMute,
          //                   child: Text(isMuted ? 'Unmute' : 'Mute'),
          //                 ),
          //                 InkWell(
          //                   onTap: isScreenSharing
          //                       ? _stopScreenShare
          //                       : _startScreenShare,
          //                   child: Text(
          //                     isScreenSharing
          //                         ? 'Stop ScreenSharing'
          //                         : 'Start Screensharing',
          //                   ),
          //                 ),
          //               ],
          //             ),

          //         ],
          //       ),
          //     ),
          //     //  Chat(channelId: widget.channelId),
          //   ],
        ),
      ),
    );
  }

  _renderVideo(user, isScreenSharing) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: (size.width / 100) * 220,
      width: double.infinity,
      child: user == widget.channelId
          ? isScreenSharing
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
              : const RtcLocalView.SurfaceView(
                  zOrderMediaOverlay: true,
                  zOrderOnTop: true,
                )
          : isScreenSharing
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
              : remoteUid.isNotEmpty
                  ? kIsWeb
                      ? RtcRemoteView.SurfaceView(
                          uid: remoteUid[0],
                          channelId: widget.channelId,
                        )
                      : RtcRemoteView.TextureView(
                          uid: remoteUid[0],
                          channelId: widget.channelId,
                        )
                  : Container(),
    );
  }
}
