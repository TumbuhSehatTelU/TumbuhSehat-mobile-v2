import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'presentation/cubit/onboarding/onboarding_cubit.dart';
import 'presentation/cubit/splash/splash_cubit.dart';
import 'presentation/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<SplashCubit>()),
        BlocProvider(create: (_) => di.sl<OnboardingCubit>()),
      ],
      child: MaterialApp(
        title: 'Tumbuh Sehat',
        theme: ThemeData(
          fontFamily: 'OpenSans',
          primarySwatch: Colors.lightGreen,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
