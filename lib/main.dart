import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/game_provider.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DotsApp());
}

class DotsApp extends StatefulWidget {
  const DotsApp({super.key});

  @override
  State<DotsApp> createState() => _DotsAppState();
}

class _DotsAppState extends State<DotsApp> {
  late final AuthProvider _authProvider;
  late final GameProvider _gameProvider;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _gameProvider = GameProvider();
    _appRouter = AppRouter(authProvider: _authProvider);
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _authProvider.initialize();
  }

  @override
  void dispose() {
    _gameProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _gameProvider),
      ],
      child: MaterialApp.router(
        title: 'Press Here',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFD700),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        routerConfig: _appRouter.router,
      ),
    );
  }
}
