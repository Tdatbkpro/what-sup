
import 'dart:async';
import 'dart:io' as dart_io;
import 'dart:math';

import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:googleapis/drive/v3.dart' hide Permission;
import 'package:whats_up/Controller/FileController.dart';
import 'package:whats_up/Pages/Chat/Voice/Globals.dart';
import 'package:whats_up/Pages/Chat/Voice/FlowShader.dart';
import 'package:whats_up/Animation/lottie_animation.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:whats_up/Pages/Chat/Voice/AudioState.dart';

enum FeedbackType { success, error, warning }
Future<void> vibrateFeedback(FeedbackType type) async{
  switch (type) {
    case FeedbackType.success:
      await Vibration.vibrate(pattern: [0, 100, 50, 100]);
      break;
    case FeedbackType.error:
      await Vibration.vibrate(pattern: [0, 300, 100, 300, 100, 300]);
      break;
    case FeedbackType.warning:
      await Vibration.vibrate(pattern: [0, 500, 200, 100]);
      break;
  }
}
  
class Recordbutton extends StatefulWidget {
  const Recordbutton({super.key, required this.controller, this.onRecordingChanged, this.waveformData, this.dataRecord});
  final AnimationController controller;
  final Function(bool)? onRecordingChanged;
  final Function(List<double>)? waveformData;
  final Function(String)? dataRecord;

  @override
  State<Recordbutton> createState() => _RecordbuttonState();
}

class _RecordbuttonState extends State<Recordbutton> {
  static const double size = 30;
  final double lockHeight = 130;
  double timerWidth =0;
  List<double> waveformData = [];

  late Animation<double> buttonScaleAnimation;
  late Animation<double> timerAnimation;
  late Animation<double> lockerAnimation;

  late FileController fileController ;
  DateTime? startTime;
  Timer? timer;
  String recordDuration = "00:00";
  late AudioRecorder record; 

  bool isLocked = false;
  bool showLottie = false;

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    fileController = Get.put(FileController());
    record = AudioRecorder();
    buttonScaleAnimation = Tween<double>(begin: 1, end: 2).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticInOut),
      ),
    );

    widget.controller.addListener(() {
      setState(() {
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
    widget.onRecordingChanged?.call(true);
  });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    timerWidth =
        MediaQuery.of(context).size.width*0.9 - 2 * Globals.defaultPadding -5;
    timerAnimation =
        Tween<double>(begin: timerWidth  , end: 0)
            .animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
    lockerAnimation =
        Tween<double>(begin: lockHeight + Globals.defaultPadding, end: 0)
            .animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: const Interval(0.2, 1, curve: Curves.easeIn),
      ),
    );
  }

   @override
void dispose() {
  debugPrint("Disposing Recordbutton");
  timer?.cancel();
  timer = null;

  () async {
    if (await record.isRecording()) {
      await record.stop(); // Đảm bảo dừng ghi
    }
    await record.dispose();
  }();

  super.dispose();
}

  @override
Widget build(BuildContext context) {
  //debugPaintSizeEnabled = true;
  return Stack(

    clipBehavior: Clip.none,
    children: [
       lockSlider(),
       cancelSlider(),
       audioButton(),
             if (isLocked)

           timerLocked(),
     

    ],
  );
}



  double normalizeAmp(double amp) {
  return ((amp + 60) / 60).clamp(0.0, 1.0); // 0..1
}

Widget buildWaveform({
  required List<double> waveformData,
  required double height,
  required double width,
}) {
  final barWidth = 2.0;
  final spacing = 1.5;

  final maxBarCount = (width / (barWidth + spacing)).floor();
  final barCount = waveformData.length.clamp(0, maxBarCount);

  // Cắt lấy phần cuối cùng của waveformData (giữ số lượng tối đa)
  final latestData = waveformData.length > maxBarCount
      ? waveformData.sublist(waveformData.length - maxBarCount)
      : waveformData;

  return SizedBox(
    width: width,
    height: height,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(latestData.length, (index) {
        final normalized = normalizeAmp(latestData[index]);
        final barHeight = normalized * height;

        return Padding(
          padding: EdgeInsets.only(right: spacing),
          child: Container(
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    ),
  );
}





  Widget lockSlider() {
    return Positioned(
      bottom: -lockerAnimation.value == 0 ?-lockerAnimation.value : -lockerAnimation.value -10,
      
      child: Container(
        height: lockHeight,
        width: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          color: Colors.blue,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const FaIcon(FontAwesomeIcons.lock, size: 20),
            const SizedBox(height: 8),
            Flexible(
              child: Flowshader(
                direction: Axis.vertical,
                child: Column(
                  children: const [
                    Icon(Icons.keyboard_arrow_up),
                    Icon(Icons.keyboard_arrow_up),
                    Icon(Icons.keyboard_arrow_up),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget cancelSlider() {
    return Positioned(
      right: -timerAnimation.value != 0 ? -timerAnimation.value -55 : -timerAnimation.value,
      //top: 2,
      bottom: 0,
      child: Container(
        height: 40,
        width: timerWidth,
        //margin: const EdgeInsets.only(left: 50),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child:
              showLottie ? LottieAnimation(size: Size(36 , 36),type: "Delete_message") : 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      LottieAnimation(size: Size(26, 26), type: "recording"),
                      Text(recordDuration, style: TextStyle(fontSize: 14, color: Colors.blue),),
                      const SizedBox(width: 4),
                      buildWaveform(height: 25,waveformData: waveformData,width: 120),
                      const SizedBox(width: 4),
                    
                      Flowshader(
                        // ignore: sort_child_properties_last
                        child: Row(
                          children: const [
                            Icon(Icons.keyboard_arrow_left),
                            Text("Trượt để hủy", style: TextStyle(fontSize: 14),)
                          ],
                        ),
                        duration: const Duration(seconds: 3),
                        flowColors: const [Colors.white, Colors.blueGrey],
                      ),
                      const SizedBox(width: size),
                    ],
                  )
        ),
      ),
    );
  }
 
  Widget timerLocked() {
  return Positioned(
    right: -12,
    top: 0,
    bottom: 1,
    child: GestureDetector(
      behavior: HitTestBehavior.translucent, // Giúp nhận sự kiện ở vùng trống
      onTap: () async {
        debugPrint("TAPPED on timerLocked");
        vibrateFeedback(FeedbackType.success);
        timer?.cancel();
        timer = null;
        startTime = null;
        recordDuration = "00:00";

        var filePath = await record.stop();

        setState(() {
          isLocked = false;
          widget.waveformData?.call(waveformData);
          widget.onRecordingChanged?.call(false);
        });
      },
      child: Container(
        height: 40,
        width: timerWidth - 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Globals.borderRadius),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LottieAnimation(size: Size(26, 26), type: "recording"),
              Text(recordDuration, style: TextStyle(fontSize: 14, color: Colors.lightBlue),),
              Flowshader(
                child: buildWaveform(waveformData: waveformData, height: 30, width: 150),
                duration: const Duration(seconds: 3),
                flowColors: const [Colors.white, Colors.blue],
              ),
              GestureDetector(
                onTap: () async {
                  debugPrint("Tapped on icon lock");
                  vibrateFeedback(FeedbackType.success);
                  timer?.cancel();
                  timer = null;
                  startTime = null;
                  recordDuration = "00:00";

                  var filePath = await record.stop();
                  setState(() {
                    isLocked = false;
                    widget.waveformData?.call(waveformData);
                    widget.onRecordingChanged?.call(false);
                    widget.dataRecord?.call(filePath!);
                  });
                },
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.circlePause,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

final LayerLink _layerLink = LayerLink();
OverlayEntry? _overlayEntry;

void _showOverlay(BuildContext context) {
  if (!mounted || _overlayEntry != null) return;

  final overlay = Overlay.of(context);
  _overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      width: 200,
      child: CompositedTransformFollower(
        link: _layerLink,
        offset: const Offset(-25, -50),
        showWhenUnlinked: false,
        child: Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromARGB(221, 54, 54, 54),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Giữ để ghi âm',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(_overlayEntry!);

  // Auto remove sau 2s
  Future.delayed(const Duration(seconds: 2), () {
    _removeOverlay();
  });
}

void _removeOverlay() {
  _overlayEntry?.remove();
  _overlayEntry = null;
}

  // Widget audioButton() {
  // Future<bool> requestMicPermission() async {
  //     var status = await Permission.microphone.status;

  //     if (!status.isGranted) {
  //       status = await Permission.microphone.request();
  //     }

  //     return status.isGranted;
  //   }
  //   return CompositedTransformTarget(
  //     link: _layerLink,
  //     child: GestureDetector(
  //       onTapDown: (_) {
  //         _showOverlay(context);
  //         Future.delayed(const Duration(seconds: 2), _removeOverlay); // auto ẩn sau 2s
  //       },
  //       child: GestureDetector(
  //         child: Transform.scale(
  //           scale: buttonScaleAnimation.value,
  //           child: Container(
  //             child: const Icon(Icons.mic, color: Colors.blue,),
  //             height: size-6,
  //             width: size-6,
  //             clipBehavior: Clip.hardEdge,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               color: Theme.of(context).primaryColor,
  //             ),
  //           ),
  //         ),
  //         onLongPressDown: (_) {
  //           debugPrint("onLongPressDown");
  //           widget.controller.forward();
  //         },
        
  //         onLongPressEnd: (details) async {
  //           debugPrint("onLongPressEnd");
        
  //           if (isCancelled(details.localPosition, context)) {
  //             vibrateFeedback(FeedbackType.warning);
        
  //             timer?.cancel();
  //             timer = null;
  //             startTime = null;
  //             recordDuration = "00:00";
        
  //             setState(() {
  //               showLottie = true;
  //             });
        
  //             Timer(const Duration(milliseconds: 1440), () async {
  //               widget.controller.reverse();
  //               debugPrint("Cancelled recording");
  //               String? filePath = await record.stop();
        
  //               if (filePath != null) {
  //                 debugPrint("File path: $filePath");
  //                 //await fileController.uploadToCloudinary(filePath);
  //                  dart_io.File(filePath).delete();// hoặc play/preview file
  //               }
  //               showLottie = false;
  //             });
  //           } else if (checkIsLocked(details.localPosition)) {
  //             widget.controller.reverse();
  //             vibrateFeedback(FeedbackType.warning);
  //             ;
  //             debugPrint("Locked recording");
  //             debugPrint(details.localPosition.dy.toString());
  //             setState(() {
  //               isLocked = true;
  //             });
  //           } else {
  //             widget.controller.reverse();
        
  //             vibrateFeedback(FeedbackType.success);
        
  //             timer?.cancel();
  //             timer = null;
  //             startTime = null;
  //             recordDuration = "00:00";
        
  //             var filePath = await record.stop();
  //            // fileController.uploadFileToCloudinarySigned(dart_io.File(filePath!));
  //            if( filePath != null) widget.dataRecord?.call(filePath);
  //            //await fileController.uploadToCloudinary(filePath!);
  //             // AudioState.files.add(filePath!);
  //             // Globals.audioListKey.currentState!
  //             //     .insertItem(AudioState.files.length - 1);
  //             widget.waveformData?.call(waveformData);
  //             widget.onRecordingChanged?.call(false);
              
  //             debugPrint(filePath);
  //             await record.dispose();
  //           }
        
  //         },
  //         onLongPressCancel: () async {
  //           debugPrint("onLongPressCancel");
  //           widget.controller.reverse();
  //           await record.dispose();
  //           //record.stop();
  //         },
  //         onLongPress: () async {
  //           try {
  //               debugPrint("onLongPress");
  //                waveformData.clear();
  //           await vibrateFeedback(FeedbackType.success);
  //           widget.onRecordingChanged?.call(true);
  //           if (await requestMicPermission()) {
  //             await record.start(
  //               const RecordConfig(
  //                 encoder: AudioEncoder.aacHe,
  //               bitRate: 128000,
  //               sampleRate: 44100
  //               ),
  //               path: "${Globals.documentPath}audio_${DateTime.now().millisecondsSinceEpoch}.m4a",
  //             );
  //             startTime = DateTime.now();
  //             timer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
  //             if (startTime == null) return; // Đảm bảo không lỗi
        
  //             final now = DateTime.now();
  //             final duration = now.difference(startTime!);
  //             final minDur = duration.inMinutes;
  //             final secDur = duration.inSeconds % 60;
  //                final amp = await record.getAmplitude();
        
  //             if (amp != null) {
  //               setState(() {
  //                 print('Amplitude: ${amp.current}');
  //                 waveformData.add(amp.current.toDouble());
  //               });
  //             }
  //             setState(() {
  //              recordDuration = "${minDur.toString().padLeft(2, '0')}:${secDur.toString().padLeft(2, '0')}";
  //             });
  //           });
        
  //           }
  //           } catch (e, stack) {
  //                 debugPrint("Lỗi khi bắt đầu ghi âm: $e");
  //       debugPrint(stack.toString());
  //           }
  //         },
  //       ),
  //     ),
  //   );
  // }
  Widget audioButton() {
  Future<bool> requestMicPermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  return CompositedTransformTarget(
    link: _layerLink,
    child: GestureDetector(
      onTap: () {
        debugPrint("===> onTapDown: show overlay");
        _showOverlay(context);
      },

      onLongPressDown: (_) {
        debugPrint("===> onLongPressDown");
        widget.controller.forward();
      },
      onLongPress: () async {
        debugPrint("===> onLongPress: Start recording");

        waveformData.clear();
        await vibrateFeedback(FeedbackType.success);
        widget.onRecordingChanged?.call(true);

        if (await requestMicPermission()) {
          await record.start(
            const RecordConfig(
              encoder: AudioEncoder.aacHe,
              bitRate: 128000,
              sampleRate: 44100,
            ),
            path:
                "${Globals.documentPath}audio_${DateTime.now().millisecondsSinceEpoch}.m4a",
          );

          startTime = DateTime.now();
          timer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
            if (startTime == null) return;

            final now = DateTime.now();
            final duration = now.difference(startTime!);
            final minDur = duration.inMinutes;
            final secDur = duration.inSeconds % 60;
            final amp = await record.getAmplitude();

            if (amp != null) {
              setState(() {
                waveformData.add(amp.current.toDouble());
              });
            }

            setState(() {
              recordDuration =
                  "${minDur.toString().padLeft(2, '0')}:${secDur.toString().padLeft(2, '0')}";
            });
          });
        }
      },
      onLongPressEnd: (details) async {
        debugPrint("===> onLongPressEnd");

        if (isCancelled(details.localPosition, context)) {
          vibrateFeedback(FeedbackType.warning);

          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = "00:00";

          setState(() => showLottie = true);

          Timer(const Duration(milliseconds: 1440), () async {
            widget.controller.reverse();
            debugPrint("Cancelled recording");
            String? filePath = await record.stop();
            if (filePath != null) dart_io.File(filePath).delete();
            showLottie = false;
          });
        } else if (checkIsLocked(details.localPosition)) {
          widget.controller.reverse();
          vibrateFeedback(FeedbackType.warning);
          debugPrint("Locked recording");
          setState(() => isLocked = true);
        } else {
          widget.controller.reverse();
          vibrateFeedback(FeedbackType.success);

          timer?.cancel();
          timer = null;
          startTime = null;
          recordDuration = "00:00";

          String? filePath = await record.stop();
          if (filePath != null) widget.dataRecord?.call(filePath);
          widget.waveformData?.call(waveformData);
          widget.onRecordingChanged?.call(false);
        }
      },
      onLongPressCancel: () async {
        debugPrint("===> onLongPressCancel");
        widget.controller.reverse();
        await record.dispose();
      },
      child: Transform.scale(
        scale: buttonScaleAnimation.value,
        child: Container(
          height: size - 6,
          width: size - 6,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          child: const Icon(Icons.mic, color: Colors.white),
        ),
      ),
    ),
  );
}

  bool checkIsLocked(Offset offset) {
    return (offset.dy < -35);
  }

  bool isCancelled(Offset offset, BuildContext context) {
    return (offset.dx < -(MediaQuery.of(context).size.width * 0.2));
  }
}