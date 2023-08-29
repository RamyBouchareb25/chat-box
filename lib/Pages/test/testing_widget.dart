import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final RefreshController _controller = RefreshController();

  Future<void> _onRefresh() async {
    await Future<void>.delayed(const Duration(seconds: 5));
    _controller.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await Future<void>.delayed(const Duration(seconds: 5));
    _controller.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test"),
      ),
      body: SmartRefresher(
        enablePullUp: true,
        enablePullDown: true,
        controller: _controller,
        onLoading: _onLoading,
        onRefresh: _onRefresh,
        child: const Center(
          child: Text("Test"),
        ),
      ),
    );
  }
}
