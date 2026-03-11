import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:woonme/l10n/app_localizations.dart';
import 'package:woonme/firebase_options.dart';
import 'package:woonme/register_page.dart';
import 'package:woonme/login_page.dart';
import 'package:woonme/services/api_service.dart';
import 'package:woonme/services/app_features_service.dart';
import 'package:woonme/filter_onboarding_page.dart';
import 'package:woonme/profile_page.dart';
import 'package:woonme/update_gate.dart';
import 'package:woonme/notification_permission_page.dart';
import 'package:woonme/widgets/city_picker.dart';
import 'package:woonme/widgets/splash_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kRadii = [5.0, 10.0, 25.0, 50.0];

Future<void> _initFCM() async {
  final messaging = FirebaseMessaging.instance;
  messaging.onTokenRefresh.listen((t) => ApiService.registerDeviceToken(t));
  FirebaseMessaging.onMessage.listen((msg) {
    final notification = msg.notification;
    if (notification != null) {
      _fcmInAppNotificationTitle = notification.title;
      _fcmInAppNotificationBody = notification.body;
    }
  });
}

String? _fcmInAppNotificationTitle;
String? _fcmInAppNotificationBody;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initFCM();
  runApp(const WoonMeApp());
}

class WoonMeApp extends StatefulWidget {
  const WoonMeApp({super.key});

  static _WoonMeAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_WoonMeAppState>();

  @override
  State<WoonMeApp> createState() => _WoonMeAppState();
}

class _WoonMeAppState extends State<WoonMeApp> {
  Locale _locale = const Locale('nl');

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language');
    if (lang != null && mounted) {
      setState(() => _locale = Locale(lang));
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale == _locale) return;
    setState(() => _locale = locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    // Re-register FCM token so the backend knows the new language
    _refreshFcmTokenLanguage(locale.languageCode);
  }

  Future<void> _refreshFcmTokenLanguage(String language) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await ApiService.registerDeviceToken(token, language: language);
      }
    } catch (_) {
      // Non-fatal
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WoonMe',
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 1,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE8ECF2)),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF0F3F8),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      home: const UpdateGate(child: AuthGate()),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'nl', label: Text('NL'), icon: Text('🇳🇱')),
        ButtonSegment(value: 'en', label: Text('EN'), icon: Text('🇬🇧')),
      ],
      selected: {lang},
      onSelectionChanged: (s) =>
          WoonMeApp.of(context)?.setLocale(Locale(s.first)),
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<List<SavedSearch>>? _future;
  String? _uid;
  bool _notifPermSeen = false;
  Future<bool>? _notifFuture;

  void _reload() => setState(() => _uid = null);

  void _onNotifComplete() => setState(() => _notifPermSeen = true);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        final user = snapshot.data;
        if (user == null) return const WelcomeScreen();

        if (_uid != user.uid) {
          _uid = user.uid;
          _future = ApiService.getSavedSearches();
          _notifPermSeen = false;
          _notifFuture = SharedPreferences.getInstance().then(
            (prefs) => prefs.getBool('notification_permission_seen') ?? false,
          );
        }

        return FutureBuilder<bool>(
          future: _notifFuture,
          builder: (context, notifSnap) {
            if (notifSnap.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            final seen = _notifPermSeen || (notifSnap.data ?? false);
            if (!seen) {
              return NotificationPermissionPage(onComplete: _onNotifComplete);
            }

            return FutureBuilder<List<SavedSearch>>(
              future: _future,
              builder: (context, ss) {
                if (ss.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }
                if (ss.hasError || (ss.data?.isNotEmpty ?? false)) {
                  return const MainShell();
                }
                return FilterOnboardingPage(onComplete: _reload);
              },
            );
          },
        );
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/woningme_logo.png',
                    height: 120,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.welcomeTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.welcomeSubtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.welcomeLogin,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      child: Text(
                        l10n.welcomeRegister,
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 48,
            right: 16,
            child: _LanguageSwitcher(),
          ),
        ],
      ),
    );
  }
}

// ─── MainShell ────────────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  List<SavedSearch> _savedSearches = [];
  String _plan = 'free';
  AppFeatures _appFeatures = const AppFeatures();

  @override
  void initState() {
    super.initState();
    _loadSavedSearches();
    _loadPlan();
    _loadAppFeatures();
  }

  Future<void> _loadAppFeatures() async {
    final features = await AppFeaturesService.get();
    if (mounted) setState(() => _appFeatures = features);
  }

  Future<void> _loadPlan() async {
    final user = await ApiService.getMe();
    if (mounted && user != null) setState(() => _plan = user.plan);
  }

  Future<void> _loadSavedSearches() async {
    final searches = await ApiService.getSavedSearches();
    if (mounted) setState(() => _savedSearches = searches);
  }

  Widget _buildAvatar(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    String initials = '?';
    if (user != null) {
      final name = user.displayName;
      final email = user.email ?? '';
      if (name != null && name.trim().isNotEmpty) {
        final parts = name.trim().split(' ');
        initials = parts.length >= 2
            ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
            : name.trim()[0].toUpperCase();
      } else if (email.isNotEmpty) {
        initials = email[0].toUpperCase();
      }
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: colorScheme.primaryContainer,
      child: user == null
          ? Icon(Icons.person, size: 18, color: colorScheme.onPrimaryContainer)
          : Text(
              initials,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('WoningMe'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
              child: _buildAvatar(context),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _AanbodTab(
            savedSearches: _savedSearches,
            onSavedSearchesChanged: _loadSavedSearches,
            appFeatures: _appFeatures,
          ),
          _ZoekenTab(
            savedSearches: _savedSearches,
            onSavedSearchesChanged: _loadSavedSearches,
            plan: _plan,
            appFeatures: _appFeatures,
          ),
          _NieuwTab(savedSearches: _savedSearches),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) {
          FocusScope.of(context).unfocus();
          setState(() => _selectedIndex = i);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.aanbodTabLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_border),
            selectedIcon: const Icon(Icons.favorite),
            label: l10n.aanbodFilterTabLabel,
          ),
          NavigationDestination(
            icon: const Icon(Icons.star_outline_rounded),
            selectedIcon: const Icon(Icons.star_rounded),
            label: l10n.aanbodNewTabLabel,
          ),
        ],
      ),
    );
  }
}

// ─── _AanbodTab ───────────────────────────────────────────────────────────────

enum _Sort {
  nieuwste('scraped_at', 'desc'),
  oudste('scraped_at', 'asc'),
  prijsLaag('huurprijs', 'asc'),
  prijsHoog('huurprijs', 'desc'),
  afstand('distance_km', 'asc');

  final String sort;
  final String order;

  const _Sort(this.sort, this.order);

  String label(AppLocalizations l10n) => switch (this) {
        _Sort.nieuwste => l10n.aanbodSortNewest,
        _Sort.oudste => l10n.aanbodSortOldest,
        _Sort.prijsLaag => l10n.aanbodSortPriceAsc,
        _Sort.prijsHoog => l10n.aanbodSortPriceDesc,
        _Sort.afstand => l10n.aanbodSortDistance,
      };
}

class _AanbodTab extends StatefulWidget {
  final List<SavedSearch> savedSearches;
  final VoidCallback onSavedSearchesChanged;
  final AppFeatures appFeatures;

  const _AanbodTab({
    required this.savedSearches,
    required this.onSavedSearchesChanged,
    required this.appFeatures,
  });

  @override
  State<_AanbodTab> createState() => _AanbodTabState();
}

class _AanbodTabState extends State<_AanbodTab> {
  Future<List<Property>>? _propertiesFuture;
  double _radiusKm = 10;
  int? _activeFilterIndex;
  _Sort _currentSort = _Sort.nieuwste;
  bool _filtersExpanded = true;
  bool _alertsBannerDismissed = false;
  bool _isOpeningAlertsBanner = false;

  // Quick-setup (empty state)
  List<String> _steden = [];
  String? _quickCity;
  double _quickRadius = 10;
  bool _quickCityError = false;
  bool _quickSaving = false;

  Future<void> _quickSave() async {
    if (_quickCity == null) {
      setState(() => _quickCityError = true);
      return;
    }
    setState(() => _quickSaving = true);
    try {
      await ApiService.createSavedSearch(
        label: '$_quickCity + ${_quickRadius.toInt()} km',
        city: _quickCity,
        radiusKm: _quickRadius,
      );
      widget.onSavedSearchesChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _quickSaving = false);
    }
  }

  Future<void> _openAlertsBanner() async {
    setState(() => _isOpeningAlertsBanner = true);
    try {
      final lang = Localizations.localeOf(context).languageCode;
      final url = await ApiService.getMagicLink(page: 'alert', lang: lang);
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isOpeningAlertsBanner = false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.savedSearches.isNotEmpty) {
      _activeFilterIndex = 0;
      _radiusKm = widget.savedSearches.first.radiusKm ?? 10;
    }
    if (widget.savedSearches.isNotEmpty) {
      _propertiesFuture = _futureForFilter(widget.savedSearches.first);
    }
    SharedPreferences.getInstance().then((prefs) {
      if (mounted && (prefs.getBool('alerts_banner_dismissed') ?? false)) {
        setState(() => _alertsBannerDismissed = true);
      }
    });
    ApiService.getSteden().then((s) {
      if (mounted) setState(() => _steden = s);
    });
  }

  @override
  void didUpdateWidget(_AanbodTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.savedSearches != widget.savedSearches) {
      if (_activeFilterIndex != null &&
          _activeFilterIndex! >= widget.savedSearches.length) {
        _applyFilterAtIndex(
            widget.savedSearches.isNotEmpty ? 0 : null);
      } else if (oldWidget.savedSearches.isEmpty &&
          widget.savedSearches.isNotEmpty) {
        _applyFilterAtIndex(0);
      }
    }
  }

  Future<List<Property>> _futureForFilter(SavedSearch? f) {
    final hasLocation = f?.city != null;
    final effectiveSort = (_currentSort == _Sort.afstand && !hasLocation)
        ? _Sort.nieuwste
        : _currentSort;
    return ApiService.getProperties(
      center: hasLocation ? f!.city : null,
      radiusKm: hasLocation ? _radiusKm : null,
      minPrijs: f?.minPrijs,
      maxPrijs: f?.maxPrijs,
      minKamers: f?.minKamers,
      minOpp: f?.minOpp,
      sort: effectiveSort.sort,
      order: effectiveSort.order,
    );
  }

  void _applyFilterAtIndex(int? i) {
    if (i != null && (i < 0 || i >= widget.savedSearches.length)) return;
    final f = (i != null) ? widget.savedSearches[i] : null;
    setState(() {
      _activeFilterIndex = i;
      _radiusKm = f?.radiusKm ?? 10;
      if (_currentSort == _Sort.afstand && f?.city == null) {
        _currentSort = _Sort.nieuwste;
      }
      _propertiesFuture = _futureForFilter(f);
    });
  }

  void _onRadiusChanged(double r) {
    setState(() {
      _radiusKm = r;
      if (_activeFilterIndex != null) {
        _propertiesFuture =
            _futureForFilter(widget.savedSearches[_activeFilterIndex!]);
      }
    });
  }

  void _retry() {
    setState(() {
      _propertiesFuture = _futureForFilter(
        _activeFilterIndex != null
            ? widget.savedSearches[_activeFilterIndex!]
            : null,
      );
    });
  }

  Widget _buildFilterCards(AppLocalizations l10n) {
    final color = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < widget.savedSearches.length; i++) ...[
              _buildFilterCard(i, color, l10n),
              if (i < widget.savedSearches.length - 1)
                const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard(int i, Color color, AppLocalizations l10n) {
    final s = widget.savedSearches[i];
    final selected = _activeFilterIndex == i;
    return GestureDetector(
      onTap: () => _applyFilterAtIndex(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 130,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : const Color(0xFFE0E5EE),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.favorite,
                    size: 14,
                    color: selected ? color : Colors.pinkAccent),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? color : const Color(0xFF1A2535),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _filterDescription(s, l10n),
              style:
                  TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusRow(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(l10n.aanbodRadiusLabel,
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(width: 8),
          ..._kRadii.map((r) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text('${r.toInt()} km'),
                  selected: _radiusKm == r,
                  onSelected: (_) => _onRadiusChanged(r),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSortRow(
      {required bool hasLocation, required AppLocalizations l10n}) {
    final sortOptions = [
      _Sort.nieuwste,
      if (hasLocation) _Sort.afstand,
      _Sort.oudste,
      _Sort.prijsLaag,
      _Sort.prijsHoog,
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Text(l10n.aanbodSortLabel,
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(width: 8),
          ...sortOptions.map((s) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(s.label(l10n)),
                  selected: _currentSort == s,
                  onSelected: (_) => setState(() {
                    _currentSort = s;
                    final f = _activeFilterIndex != null
                        ? widget.savedSearches[_activeFilterIndex!]
                        : null;
                    _propertiesFuture = _futureForFilter(f);
                  }),
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.savedSearches.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.search, size: 48, color: Colors.black26),
              const SizedBox(height: 16),
              Text(
                l10n.aanbodEmptyTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.aanbodEmptyBody,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              CityPickerField(
                value: _quickCity,
                steden: _steden,
                hasError: _quickCityError,
                errorText: _quickCityError ? l10n.zoekenCityRequired : null,
                label: l10n.zoekenCityLabel,
                onChanged: (v) => setState(() {
                  _quickCity = v;
                  if (_quickCityError) _quickCityError = false;
                }),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(l10n.filterRadiusLabel,
                        style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(width: 8),
                    ..._kRadii.map((r) => Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text('${r.toInt()} km'),
                            selected: _quickRadius == r,
                            onSelected: (_) => setState(() => _quickRadius = r),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _quickSaving ? null : _quickSave,
                  child: _quickSaving
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(l10n.zoekenNewFilter),
                ),
              ),
            ],
          ),
        ),
      );
    }
    final activeFilter = _activeFilterIndex != null
        ? widget.savedSearches[_activeFilterIndex!]
        : null;
    final showRadius = activeFilter?.city != null;

    return Column(
      children: [
        if (widget.appFeatures.alerts && !_alertsBannerDismissed)
          Dismissible(
            key: const Key('alerts_banner'),
            direction: DismissDirection.horizontal,
            onDismissed: (_) async {
              setState(() => _alertsBannerDismissed = true);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('alerts_banner_dismissed', true);
            },
            child: GestureDetector(
              onTap: _isOpeningAlertsBanner ? null : _openAlertsBanner,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF3FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFCFFF)),
                ),
                child: Row(
                  children: [
                    _isOpeningAlertsBanner
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.notifications_outlined,
                            color: Color(0xFF3B5BDB), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.aanbodBannerText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF3B5BDB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right,
                        color: Color(0xFF3B5BDB), size: 18),
                  ],
                ),
              ),
            ),
          ),
        if (widget.savedSearches.isNotEmpty)
          DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.white,
              border:
                  Border(bottom: BorderSide(color: Color(0xFFE8ECF2))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  onTap: () =>
                      setState(() => _filtersExpanded = !_filtersExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Text(
                          _filtersExpanded
                              ? l10n.aanbodFiltersHeader
                              : l10n.aanbodFiltersHeaderCollapsed(
                                  widget.savedSearches[
                                      _activeFilterIndex ?? 0].label),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _filtersExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 20,
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: _filtersExpanded
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildFilterCards(l10n),
                            if (showRadius) _buildRadiusRow(l10n),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                _buildSortRow(hasLocation: showRadius, l10n: l10n),
              ],
            ),
          ),
        Expanded(
          child: FutureBuilder<List<Property>>(
            future: _propertiesFuture,
            builder: (context, snapshot) {
              if (_propertiesFuture == null ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                final raw = '${snapshot.error}'.replaceFirst('Exception: ', '');
                final noConnection = raw == '__no_connection__';
                final noInternet   = raw == '__no_internet__';
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          noInternet
                              ? Icons.signal_wifi_off_rounded
                              : noConnection
                                  ? Icons.wifi_off_rounded
                                  : Icons.error_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          noInternet
                              ? 'Geen internetverbinding'
                              : noConnection
                                  ? 'Tijdelijk niet bereikbaar'
                                  : 'Onbekend probleem',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          noInternet
                              ? 'Zorg voor een internetverbinding en probeer opnieuw.'
                              : noConnection
                                  ? 'Probeer het over een moment opnieuw.'
                                  : 'Probeer het opnieuw of kom later terug.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: Text(l10n.aanbodErrorRetry),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final properties = snapshot.data!;
              if (properties.isEmpty) {
                return Center(child: Text(l10n.aanbodNoResults));
              }
              return ListView.builder(
                itemCount: properties.length,
                itemBuilder: (context, index) =>
                    PropertyCard(property: properties[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// CityPickerField and CityPickerSheet are defined in widgets/city_picker.dart

// ─── _ZoekenTab ───────────────────────────────────────────────────────────────

String _filterDescription(SavedSearch s, AppLocalizations l10n) {
  final parts = <String>[];
  if (s.city != null) {
    parts.add('${s.city} · ${s.radiusKm?.toInt() ?? 10} km');
  } else {
    parts.add(l10n.filterWholeNL);
  }
  if (s.minPrijs != null && s.maxPrijs != null) {
    parts.add('€${s.minPrijs}–€${s.maxPrijs}');
  } else if (s.minPrijs != null) {
    parts.add(l10n.filterFromPrice(s.minPrijs!));
  } else if (s.maxPrijs != null) {
    parts.add(l10n.filterUpToPrice(s.maxPrijs!));
  }
  if (s.minKamers != null) {
    parts.add(l10n.filterRooms(
        '${s.minKamers}${s.minKamers == 4 ? '+' : ''}'));
  }
  if (s.minOpp != null) parts.add('${s.minOpp} m²+');
  return parts.join(' · ');
}

class _ZoekenTab extends StatefulWidget {
  final List<SavedSearch> savedSearches;
  final VoidCallback onSavedSearchesChanged;
  final String plan;
  final AppFeatures appFeatures;

  const _ZoekenTab({
    required this.savedSearches,
    required this.onSavedSearchesChanged,
    required this.plan,
    required this.appFeatures,
  });

  @override
  State<_ZoekenTab> createState() => _ZoekenTabState();
}

class _ZoekenTabState extends State<_ZoekenTab> {
  final _minPrijsController = TextEditingController();
  final _maxPrijsController = TextEditingController();
  final _minOppController = TextEditingController();
  double _radiusKm = 10.0;
  int? _minKamers;
  bool _isCreating = false;
  bool _isSaving = false;
  String? _selectedCity;
  List<String> _steden = [];

  int? get _searchLimit => const {'free': 2, 'premium': 10}[widget.plan];

  bool get _isLimitReached {
    final limit = _searchLimit;
    return limit != null && widget.savedSearches.length >= limit;
  }

  bool _isOpeningAlerts = false;
  bool _cityError = false;

  Future<void> _openAlertSettings() async {
    setState(() => _isOpeningAlerts = true);
    try {
      final lang = Localizations.localeOf(context).languageCode;
      final url = await ApiService.getMagicLink(page: 'alert', lang: lang);
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isOpeningAlerts = false);
    }
  }

  @override
  void initState() {
    super.initState();
    ApiService.getSteden().then((steden) {
      if (mounted) setState(() => _steden = steden);
    });
  }

  @override
  void dispose() {
    _minPrijsController.dispose();
    _maxPrijsController.dispose();
    _minOppController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _selectedCity = null;
    _minPrijsController.clear();
    _maxPrijsController.clear();
    _minOppController.clear();
    setState(() {
      _radiusKm = 10.0;
      _minKamers = null;
    });
  }

  void _applyFilter(SavedSearch search) {
    _minPrijsController.text = search.minPrijs?.toString() ?? '';
    _maxPrijsController.text = search.maxPrijs?.toString() ?? '';
    _minOppController.text = search.minOpp?.toString() ?? '';
    setState(() {
      _selectedCity = search.city;
      _radiusKm = search.radiusKm ?? 10.0;
      _minKamers = search.minKamers;
      _isCreating = true;
    });
  }

  Future<void> _deleteFilter(int id) async {
    await ApiService.deleteSavedSearch(id);
    widget.onSavedSearchesChanged();
  }

  Future<void> _saveCurrentFilter() async {
    final l10n = AppLocalizations.of(context)!;
    final city = _selectedCity;
    if (city == null) {
      setState(() => _cityError = true);
      return;
    }
    final minPrijs = int.tryParse(_minPrijsController.text.trim());
    final maxPrijs = int.tryParse(_maxPrijsController.text.trim());
    final minOpp = int.tryParse(_minOppController.text.trim());

    final parts = <String>[];
    parts.add('$city + ${_radiusKm.toInt()} km');
    if (minPrijs != null && maxPrijs != null) {
      parts.add('€$minPrijs–€$maxPrijs');
    } else if (minPrijs != null) {
      parts.add(l10n.filterFromPrice(minPrijs));
    } else if (maxPrijs != null) {
      parts.add(l10n.filterUpToPrice(maxPrijs));
    }
    if (_minKamers != null) {
      parts.add(l10n.filterRooms('$_minKamers${_minKamers == 4 ? '+' : ''}'));
    }
    if (minOpp != null) parts.add('$minOpp m²+');
    final label =
        parts.isEmpty ? l10n.filterDefaultLabel : parts.join(', ');

    setState(() => _isSaving = true);
    try {
      await ApiService.createSavedSearch(
        label: label,
        city: city,
        radiusKm: _radiusKm,
        minPrijs: minPrijs,
        maxPrijs: maxPrijs,
        minKamers: _minKamers,
        minOpp: minOpp,
      );
      widget.onSavedSearchesChanged();
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.zoekenSavedSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isCreating ? _buildForm() : _buildList();
  }

  // ── Lijstweergave ──────────────────────────────────────────────────────────

  Widget _buildList() {
    final l10n = AppLocalizations.of(context)!;
    final searches = widget.savedSearches;
    return Column(
      children: [
        if (widget.appFeatures.alerts)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: InkWell(
              onTap: _isOpeningAlerts ? null : _openAlertSettings,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isOpeningAlerts
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.notifications_outlined),
                    const SizedBox(width: 8),
                    Text(
                      l10n.zoekenStayUpdated,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (searches.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                l10n.zoekenNoFilters,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: searches.length,
              itemBuilder: (ctx, i) {
                final s = searches[i];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.favorite,
                        color: Colors.pinkAccent),
                    title: Text(s.label,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle:
                        Text(_filterDescription(s, l10n)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.appFeatures.alerts)
                          IconButton(
                            icon: Icon(
                              s.alert
                                  ? Icons.notifications_active
                                  : Icons.notifications_none,
                              color: s.alert ? Colors.amber : Colors.black45,
                            ),
                            tooltip: 'Notificatie-instellingen',
                            onPressed: _isOpeningAlerts ? null : _openAlertSettings,
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          tooltip: 'Verwijderen',
                          onPressed: () => _deleteFilter(s.id),
                        ),
                      ],
                    ),
                    onTap: () => _applyFilter(s),
                  ),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isLimitReached
                      ? (widget.appFeatures.alerts
                          ? (_isOpeningAlerts ? null : _openAlertSettings)
                          : null)
                      : () {
                          _clearForm();
                          setState(() => _isCreating = true);
                        },
                  icon: (_isLimitReached && _isOpeningAlerts)
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.add),
                  label: Text(l10n.zoekenNewFilter),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Formulierweergave ─────────────────────────────────────────────────────

  Widget _buildForm() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Material(
          color: Colors.white,
          elevation: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      padding: EdgeInsets.zero,
                      onPressed: () => setState(() => _isCreating = false),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.zoekenNewFilter,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Stad
                CityPickerField(
                  value: _selectedCity,
                  steden: _steden,
                  hasError: _cityError,
                  errorText: _cityError ? l10n.zoekenCityRequired : null,
                  label: l10n.zoekenCityLabel,
                  onChanged: (v) => setState(() {
                    _selectedCity = v;
                    if (_cityError) _cityError = false;
                  }),
                ),
                const SizedBox(height: 10),

                // Straal
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Text(l10n.filterRadiusLabel,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black54)),
                      const SizedBox(width: 8),
                      ..._kRadii.map((r) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text('${r.toInt()} km'),
                              selected: _radiusKm == r,
                              onSelected: (_) =>
                                  setState(() => _radiusKm = r),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Huurprijs
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minPrijsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.filterMinRentLabel,
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _maxPrijsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.filterMaxRentLabel,
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Min. kamers
                Text(l10n.filterMinRoomsLabel,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54)),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final k in [1, 2, 3, 4])
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(k == 4 ? '4+' : '$k'),
                            selected: _minKamers == k,
                            onSelected: (_) => setState(
                                () => _minKamers = _minKamers == k ? null : k),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Min. oppervlakte
                TextField(
                  controller: _minOppController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.filterMinSizeLabel,
                    prefixIcon: const Icon(Icons.square_foot_outlined),
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),

                // Opslaan
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveCurrentFilter,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.zoekenSave),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── _NieuwTab ────────────────────────────────────────────────────────────────

class _NieuwTab extends StatefulWidget {
  final List<SavedSearch> savedSearches;

  const _NieuwTab({required this.savedSearches});

  @override
  State<_NieuwTab> createState() => _NieuwTabState();
}

class _NieuwTabState extends State<_NieuwTab> {
  late Future<List<Property>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_NieuwTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.savedSearches != widget.savedSearches) {
      setState(() => _load());
    }
  }

  void _load() {
    _future = _fetchAll();
  }

  Future<List<Property>> _fetchAll() async {
    if (widget.savedSearches.isEmpty) return [];
    final results = await Future.wait(
      widget.savedSearches.map((s) => ApiService.getProperties(
            nieuw: true,
            center: s.city,
            radiusKm: s.city != null ? (s.radiusKm ?? 10) : null,
            minPrijs: s.minPrijs,
            maxPrijs: s.maxPrijs,
            minKamers: s.minKamers,
            minOpp: s.minOpp,
          )),
    );
    final seen = <int>{};
    final combined = <Property>[];
    for (final list in results) {
      for (final p in list) {
        if (seen.add(p.id)) combined.add(p);
      }
    }
    combined.sort((a, b) {
      final da = DateTime.tryParse(
              a.firstSeenAt ?? a.scrapedAt ?? '') ??
          DateTime(2000);
      final db = DateTime.tryParse(
              b.firstSeenAt ?? b.scrapedAt ?? '') ??
          DateTime(2000);
      return db.compareTo(da);
    });
    return combined;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: () async => setState(() => _load()),
      child: FutureBuilder<List<Property>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(l10n.nieuwErrorLoadFailed,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: () => setState(() => _load()),
                        child: Text(l10n.nieuwRetry)),
                  ],
                ),
              ),
            );
          }

          final properties = snapshot.data ?? [];
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final monday =
              today.subtract(Duration(days: today.weekday - 1));

          final vandaag = properties.where((p) {
            final s = DateTime.tryParse(
                    p.firstSeenAt ?? p.scrapedAt ?? '')
                ?.toLocal();
            return s != null && !s.isBefore(today);
          }).toList();

          final dezeWeek = properties.where((p) {
            final s = DateTime.tryParse(
                    p.firstSeenAt ?? p.scrapedAt ?? '')
                ?.toLocal();
            return s != null &&
                s.isBefore(today) &&
                !s.isBefore(monday);
          }).toList();

          if (widget.savedSearches.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      l10n.nieuwEmptyNoFilter,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          if (vandaag.isEmpty && dezeWeek.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_outline_rounded,
                        size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      l10n.nieuwEmptyNoResults,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          final items = <Widget>[];
          if (vandaag.isNotEmpty) {
            items.add(_sectionHeader(l10n.nieuwToday));
            items.addAll(vandaag.map((p) => PropertyCard(property: p)));
          }
          if (dezeWeek.isNotEmpty) {
            items.add(_sectionHeader(l10n.nieuwThisWeek));
            items.addAll(
                dezeWeek.map((p) => PropertyCard(property: p)));
          }

          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            children: items,
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── PropertyCard ─────────────────────────────────────────────────────────────

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  String? _freshnessLabel(AppLocalizations l10n) {
    final dateStr = property.firstSeenAt ?? property.scrapedAt;
    if (dateStr == null) return null;
    final scraped = DateTime.tryParse(dateStr)?.toLocal();
    if (scraped == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday =
        today.subtract(Duration(days: today.weekday - 1));
    if (!scraped.isBefore(today)) return l10n.aanbodBadgeNew;
    if (!scraped.isBefore(monday)) return l10n.aanbodBadgeRecent;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final hasFeatures =
        property.kamers != null || property.oppervlakte != null;
    final freshness = _freshnessLabel(l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: property.sources.isEmpty
              ? null
              : () {
                  if (property.sources.length == 1) {
                    launchUrl(Uri.parse(property.sources.first.url),
                        mode: LaunchMode.inAppBrowserView);
                  } else {
                    PropertyCard._showSourcePicker(context, property);
                  }
                },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8ECF2)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Adres + type badge ─────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.straat ?? l10n.aanbodUnknownAddress,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          if (property.stad != null) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 12, color: Colors.grey[400]),
                                const SizedBox(width: 2),
                                Text(
                                  [property.postcode, property.stad]
                                      .whereType<String>()
                                      .join(' '),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (freshness != null ||
                        property.woningType != null) ...[
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (freshness != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: freshness == l10n.aanbodBadgeNew
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEF9C3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                freshness,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: freshness == l10n.aanbodBadgeNew
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFCA8A04),
                                ),
                              ),
                            ),
                          if (freshness != null &&
                              property.woningType != null)
                            const SizedBox(height: 4),
                          if (property.woningType != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                property.woningType!,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 14),

                // ── Prijs ──────────────────────────────────────────────
                Text(
                  property.huurprijsTxt ?? '–',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),

                // ── Kenmerken ─────────────────────────────────────────
                if (hasFeatures) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (property.kamers != null)
                        _featureChip(
                            Icons.king_bed_outlined,
                            l10n.filterRooms('${property.kamers}')),
                      if (property.kamers != null &&
                          property.oppervlakte != null)
                        const SizedBox(width: 6),
                      if (property.oppervlakte != null)
                        _featureChip(Icons.square_foot_outlined,
                            '${property.oppervlakte} m²'),
                    ],
                  ),
                ],

                // ── Bron ──────────────────────────────────────────────
                if (property.sources.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.link, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        property.sources.length == 1
                            ? property.sources.first.source
                            : l10n.propertySourceCount(property.sources.length),
                        style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _showSourcePicker(BuildContext context, Property property) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.propertySourcePickerTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              property.straat ?? '',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            ...property.sources.map(
              (s) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(s.source,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.open_in_new, size: 18),
                onTap: () {
                  Navigator.pop(ctx);
                  launchUrl(Uri.parse(s.url),
                      mode: LaunchMode.inAppBrowserView);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
