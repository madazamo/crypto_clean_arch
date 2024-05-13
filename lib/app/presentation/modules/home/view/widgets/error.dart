import 'package:flutter/material.dart';

import '../../../../../domain/failures/http_request_failure.dart';

class HomeError extends StatelessWidget {
  const HomeError({required this.failure, super.key});
  final HttpRequestFailure failure;

  @override
  Widget build(BuildContext context) {
    final message = failure.when(
        network: () => 'Check your internet connection',
        notFound: () => 'Check your internet connection',
        server: () => 'Server error',
        unauthorized: () => 'Unauthorized',
        badRequest: () => 'Bad request',
        local: () => 'Unknown error');
    return Center(child: Text(message));
  }
}
