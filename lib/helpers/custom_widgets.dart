import 'package:flutter/material.dart';

import 'shimmer_helper.dart';

class CustomFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final bool isShimmerLoading;
  final Widget Function(AsyncSnapshot<T> snapshot) child;
  const CustomFutureBuilder(
      {Key? key,
      required this.future,
      required this.child,
      this.isShimmerLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, AsyncSnapshot<T> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            // case ConnectionState.done:
            if (isShimmerLoading) {
              final width = (MediaQuery.of(context).size.width - 64) / 3;
              return Row(
                children: List.generate(
                    3,
                    (index) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ShimmerHelper()
                              .buildBasicShimmer(height: 130.0, width: width),
                        ))),
              );
            }
            return const Center(child: CircularProgressIndicator.adaptive());
          default:
            if (snapshot.hasError) {
              return Center(
                  child: Text(
                      'Something went wrong: ${snapshot.error.toString()}'));
            } else if (!snapshot.hasData) {
              return const Center(
                  child: Text('No data is Available at this moment'));
            }
            return child(snapshot);
        }
      },
    );
  }
}

class ConnectionStateWidget extends StatelessWidget {
  final AppState appState;
  final Widget child;
  const ConnectionStateWidget(
      {Key? key, required this.appState, this.child = const SizedBox.shrink()})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (appState) {
      case AppState.connectionError:
        return const Center(
            child: Padding(
                padding: EdgeInsets.all(16.0),
                child:
                    Text('Please check if you are connected to the internet')));
      case AppState.loading:
        return const Center(child: CircularProgressIndicator.adaptive());
      case AppState.error:
        return const Center(child: Text('Something went wrong'));
      case AppState.empty:
        return const Center(child: Text('No data is available at this moment'));
      default:
        return child;
    }
  }
}

enum AppState {
  initial,
  loading,
  loaded,
  error,
  empty,
  disabled,
  connectionError
}
