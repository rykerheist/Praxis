import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../theme.dart';
import '../widgets/giles_lens.dart';

class SessionScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionScreen({
    super.key,
    required this.sessionId,
  });

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  bool _controlsVisible = true;
  Timer? _inactivityTimer;
  bool _isRecording = false;
  late final AudioRecorder _audioRecorder;

  @override
  void initState() {
    super.initState();
    _startInactivityTimer();
    _audioRecorder = AudioRecorder();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  void _onUserInteraction() {
    if (!_controlsVisible) {
      setState(() {
        _controlsVisible = true;
      });
    }
    _startInactivityTimer();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // STOP RECORDING
      final path = await _audioRecorder.stop();
      setState(() { _isRecording = false; });
      
      if (path != null) {
        // Upload logic
        _uploadRecording(path);
      }
    } else {
      // START RECORDING
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/session_${widget.sessionId}_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(),
          path: path,
        );
        setState(() { _isRecording = true; });
      }
    }
  }

  Future<void> _uploadRecording(String filePath) async {
    try {
      final fileFn = filePath.split('/').last;
      final fileBytes = await File(filePath).readAsBytes();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Uploading audio.")),
        );
      }

      await Supabase.instance.client.storage
          .from('session_recordings')
          .uploadBinary(fileFn, fileBytes);

       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload complete. Analyzing.")),
        );
        
        // Trigger the edge function
        await Supabase.instance.client.functions.invoke(
          'process-session',
          body: {
            'sessionId': widget.sessionId,
            'filename': fileFn,
          },
        );
      }
    } catch (e) {
      debugPrint("Upload/Analysis error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PraxisTheme.creamVellum,
      body: MouseRegion(
        onHover: (_) => _onUserInteraction(),
        child: GestureDetector(
          onTap: _onUserInteraction,
          behavior: HitTestBehavior.translucent, // Catch taps on empty space
          child: Stack(
            children: [
              // 1. Core Content Area (The "Invisible" Workspace)
              // This is where transcripts or minimalistic notes might appear.
              // For now, it's distraction-free space.
              Center(
                child: Text(
                  _isRecording ? "LISTENING..." : "SESSION PAUSED",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: PraxisTheme.charcoalInk.withAlpha(20), // Very faint
                    letterSpacing: 8.0,
                  ),
                ),
              ),

              // 2. The "Giles" Indicator (Top Right)
              Positioned(
                top: 24,
                right: 24,
                child: GilesLens(
                  size: 14, // Small indicator
                  state: _isRecording ? GilesState.speaking : GilesState.idle,
                ),
              ),

              // 3. The Controls (Fade in/out)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _controlsVisible ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildControlBtn(
                            icon: Icons.mic_off_outlined,
                            label: "MUTE",
                            onTap: () {},
                          ),
                          const SizedBox(width: 32),
                          // Primary Record Button
                          GestureDetector(
                            onTap: _toggleRecording,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _isRecording 
                                    ? PraxisTheme.charcoalInk 
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: PraxisTheme.charcoalInk, 
                                  width: 2
                                ),
                              ),
                              child: Icon(
                                _isRecording ? Icons.stop : Icons.mic,
                                color: _isRecording 
                                    ? PraxisTheme.creamVellum 
                                    : PraxisTheme.charcoalInk,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 32),
                          _buildControlBtn(
                            icon: Icons.exit_to_app,
                            label: "END",
                            onTap: () {
                              // Go back to Dashboard
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: PraxisTheme.charcoalInk.withAlpha(150)),
          iconSize: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: PraxisTheme.charcoalInk.withAlpha(100),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
