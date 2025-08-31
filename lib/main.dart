import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'style/app_colors.dart';
import 'feature/home/home_screen.dart';
import 'feature/landing/landing_screen.dart';

class LoggingNavigatorObserver extends NavigatorObserver {
  void _log(
    String event,
    Route<dynamic>? route, [
    Route<dynamic>? previousRoute,
  ]) {
    final name = route?.settings.name ?? route?.toString();
    final prev = previousRoute?.settings.name ?? previousRoute?.toString();
    debugPrint(
      '[NAVIGATOR] ' +
          event +
          ' -> ' +
          (name ?? 'null') +
          ' | from=' +
          (prev ?? 'null'),
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _log('didPush', route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log('didPop', route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _log('didRemove', route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log('didReplace', newRoute, oldRoute);
  }
}

class UserSession extends ChangeNotifier {
  String? _uuid;
  String? get uuid => _uuid;
  void setUuid(String uuid) {
    _uuid = uuid;
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => UserSession(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Happy Day',
      navigatorObservers: [LoggingNavigatorObserver()],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary500,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.gray100,
      ),
      // 라우팅 설정
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingScreen(),
        '/home': (context) => const HomeScreen(),
      },
      // 404 페이지 처리
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('페이지를 찾을 수 없습니다'),
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.gray00,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    '요청하신 페이지를 찾을 수 없습니다',
                    style: TextStyle(fontSize: 18, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/'),
                    child: const Text('홈으로 돌아가기'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
