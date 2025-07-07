import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String appName;
  final String appUrl;

  WebViewScreen({required this.appName, required this.appUrl});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isRefreshing = false;
  double _dragStartY = 0;
  bool _canTriggerRefresh = true;

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) async {
                // Set viewport for high quality rendering
                await _controller.runJavaScript('''
              var meta = document.createElement('meta');
              meta.name = 'viewport';
              meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
              document.head.appendChild(meta);
            ''');
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.appUrl));
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await _controller.reload();
    await Future.delayed(Duration(milliseconds: 600));
    setState(() => _isRefreshing = false);
  }

  Future<bool> _isPageScrolledToTop() async {
    try {
      final result = await _controller.runJavaScriptReturningResult(
        "window.scrollY;",
      );
      if (result != null) {
        final y =
            int.tryParse(result.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
            0;
        return y == 0;
      }
    } catch (_) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _controller.canGoBack()) {
          _controller.goBack();
          return false; // Don't exit the app
        }
        return true; // Exit the app
      },
      child: Scaffold(
        body: SafeArea(
          child: Listener(
            onPointerDown: (event) {
              _dragStartY = event.position.dy;
              _canTriggerRefresh = true;
            },
            onPointerMove: (event) async {
              double drag = event.position.dy - _dragStartY;

              if (drag > 100 && _canTriggerRefresh) {
                bool atTop = await _isPageScrolledToTop();
                if (atTop) {
                  _canTriggerRefresh = false;
                  _handleRefresh();
                }
              }
            },
            onPointerUp: (_) {
              _dragStartY = 0;
              _canTriggerRefresh = true;
            },
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isRefreshing)
                  Positioned(
                    top: 10,
                    left: MediaQuery.of(context).size.width / 2 - 15,
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
