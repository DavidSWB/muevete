import 'package:flutter/material.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/utils/youtube_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExerciseVideoPlayer extends StatefulWidget {
  const ExerciseVideoPlayer({
    super.key,
    required this.visualPath,
    this.aspectRatio = 16 / 9,
  });

  final String visualPath;
  final double aspectRatio;

  @override
  State<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends State<ExerciseVideoPlayer>
    with WidgetsBindingObserver {
  WebViewController? _controller;
  String? _videoId;
  bool _hasError = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant ExerciseVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visualPath != widget.visualPath) {
      _initializePlayer();
    }
  }

  void _initializePlayer() {
    _hasError = false;
    _isLoading = true;
    _videoId = extractYouTubeId(widget.visualPath);

    if (_videoId == null) {
      _hasError = true;
      _isLoading = false;
      return;
    }

    final controller = WebViewController();
    _controller = controller;

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            if (url.startsWith('https://www.youtube-nocookie.com') ||
                url == 'about:blank') {
              return NavigationDecision.navigate;
            }
            final uri = Uri.tryParse(url);
            if (uri != null) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            return NavigationDecision.prevent;
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (WebResourceError error) {
            // Only consider main frame errors as genuine failures
            if (error.isForMainFrame == true &&
                error.errorCode != -1 &&
                error.errorCode != -999) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _isLoading = false;
                });
              }
            }
          },
        ),
      )
      ..loadHtmlString(
        _buildHtml(_videoId!),
        baseUrl: 'https://www.youtube-nocookie.com',
      );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _pauseVideo();
    }
  }

  void _pauseVideo() {
    if (_controller != null && !_hasError && _videoId != null) {
      _controller?.runJavaScript(
        "try { document.getElementById('yt-player')?.contentWindow?.postMessage('{\"event\":\"command\",\"func\":\"pauseVideo\",\"args\":\"\"}', '*'); } catch (e) {}",
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pauseVideo();
    _controller = null;
    super.dispose();
  }

  String _buildHtml(String id) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 100%;
      height: 100%;
      background-color: #000000;
      overflow: hidden;
    }
    .iframe-container {
      position: relative;
      width: 100%;
      height: 100%;
    }
    iframe {
      width: 100%;
      height: 100%;
      border: 0;
      display: block;
    }
  </style>
</head>
<body>
  <div class="iframe-container">
    <iframe
      id="yt-player"
      src="https://www.youtube-nocookie.com/embed/$id?enablejsapi=1&autoplay=0&rel=0&playsinline=1&origin=https://www.youtube-nocookie.com"
      title="YouTube video player"
      frameborder="0"
      referrerpolicy="strict-origin-when-cross-origin"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      allowfullscreen>
    </iframe>
  </div>
</body>
</html>
''';
  }

  Future<void> _openInYouTube() async {
    final urlString = _videoId != null
        ? 'https://www.youtube.com/watch?v=$_videoId'
        : widget.visualPath;

    final uri = Uri.tryParse(urlString);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        // Fallback: try default platform mode
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _videoId == null) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: _FallbackCard(
          visualPath: widget.visualPath,
          onOpenYouTube: _openInYouTube,
        ),
      );
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        children: [
          if (_controller != null)
            WebViewWidget(controller: _controller!),
          if (_isLoading)
            const ColoredBox(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FallbackCard extends StatelessWidget {
  const _FallbackCard({
    required this.visualPath,
    required this.onOpenYouTube,
  });

  final String visualPath;
  final VoidCallback onOpenYouTube;

  @override
  Widget build(BuildContext context) {
    final canOpen = visualPath.trim().isNotEmpty &&
        (visualPath.startsWith('http://') ||
            visualPath.startsWith('https://') ||
            visualPath.startsWith('youtu'));

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 48,
              color: Colors.white70,
            ),
            const SizedBox(height: 12),
            const Text(
              'Video unavailable in player',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (canOpen) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onOpenYouTube,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Open in YouTube'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
