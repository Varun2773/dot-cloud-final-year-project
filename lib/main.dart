import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dot_final_year_project/webview_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? shortcutName;
  String? shortcutUrl;

  static const platform = MethodChannel('com.yourapp/shortcut');

  @override
  void initState() {
    super.initState();
    _checkForShortcutIntent();
  }

  Future<void> _checkForShortcutIntent() async {
    final MethodChannel shortcutIntent = MethodChannel("flutter/intent");
    final intent = await shortcutIntent.invokeMethod<Map>('getInitialIntent');

    final url = intent?['url'];
    final name = intent?['name'];
    if (url != null && name != null) {
      setState(() {
        shortcutName = name;
        shortcutUrl = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (shortcutUrl != null && shortcutName != null) {
      return MaterialApp(
        home: WebViewScreen(appName: shortcutName!, appUrl: shortcutUrl!),
      );
    }

    return MaterialApp(
      title: 'WebApp Launcher',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NavigationScreen(),
    );
  }
}

class NavigationScreen extends StatefulWidget {
  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [HomeScreen(), CloudServiceScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.web), label: 'WebApps'),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'CloudService',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<WebAppItem> webApps = [
    WebAppItem(
      name: 'Instagram',
      url: 'https://instagram.com',
      iconName: 'instagram.png',
    ),
    WebAppItem(
      name: 'Facebook',
      url: 'https://facebook.com',
      iconName: 'facebook.png',
    ),
    WebAppItem(name: 'X', url: 'https://x.com', iconName: 'x.png'),
    WebAppItem(
      name: 'GitHub',
      url: 'https://github.com',
      iconName: 'github.png',
    ),
    WebAppItem(
      name: 'Trading View',
      url: 'https://in.tradingview.com',
      iconName: 'tradingView.png',
    ),
    WebAppItem(name: 'IRCTC', url: 'https:irctc.co.in', iconName: 'irctc.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Available WebApps')),
      body: ListView.builder(
        itemCount: webApps.length,
        itemBuilder: (context, index) {
          final app = webApps[index];
          return ListTile(
            title: Text(app.name),
            subtitle: Text(app.url),
            trailing: ElevatedButton(
              child: Text('Install'),
              onPressed: () async {
                const platform = MethodChannel('com.yourapp/shortcut');
                try {
                  await platform.invokeMethod('createShortcut', {
                    'name': app.name,
                    'url': app.url,
                    'icon': app.iconName,
                  });
                } catch (e) {
                  print('Failed to create shortcut: $e');
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class CloudServiceScreen extends StatelessWidget {
  final List<WebAppItem> webApps = [
    WebAppItem(
      name: 'Spotify',
      url: 'https://16-170-236-59:6080',
      iconName: 'spotify.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cloud Services')),
      body: ListView.builder(
        itemCount: webApps.length,
        itemBuilder: (context, index) {
          final app = webApps[index];
          return ListTile(
            title: Text(app.name),
            subtitle: Text(app.url),
            trailing: ElevatedButton(
              child: Text('Install'),
              onPressed: () async {
                const platform = MethodChannel('com.yourapp/shortcut');
                try {
                  await platform.invokeMethod('createShortcut', {
                    'name': app.name,
                    'url': app.url,
                    'icon': app.iconName,
                  });
                } catch (e) {
                  print('Failed to create shortcut: $e');
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class WebAppItem {
  final String name;
  final String url;
  final String iconName;
  WebAppItem({required this.name, required this.url, required this.iconName});
}
