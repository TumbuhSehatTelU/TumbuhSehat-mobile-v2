// ignore_for_file: avoid_print

import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('--- BLOC OBSERVER ---');
    print('Bloc: ${bloc.runtimeType}');
    print('Event: (Implicit)');
    print('Current State: ${transition.currentState.runtimeType}');
    print('Next State: ${transition.nextState.runtimeType}');
    print('---------------------');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('--- BLOC ERROR ---');
    print('Bloc: ${bloc.runtimeType}');
    print('Error: $error');
    print('------------------');
    super.onError(bloc, error, stackTrace);
  }
}
