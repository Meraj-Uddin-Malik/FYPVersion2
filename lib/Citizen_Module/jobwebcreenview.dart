import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JobWebScreen extends StatefulWidget {
  const JobWebScreen({super.key});

  @override
  State<JobWebScreen> createState() => _JobWebScreenState();
}

class _JobWebScreenState extends State<JobWebScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse("https://sindhpolice.gov.pk/jobs")); // Change URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Portal"),
        titleTextStyle: TextStyle(
          color: Color(0x802A489E).withAlpha((1 * 255).toInt()),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0x802A489E).withAlpha((1 * 255).toInt()), // Red color for back icon
            size: 18, // Smaller size
          ),
          onPressed: () {
            Navigator.pop(context); // Pops the current screen
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
