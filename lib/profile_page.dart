import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:woonme/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woonme/feedback_page.dart';
import 'package:woonme/main.dart';
import 'package:woonme/services/api_service.dart';
import 'package:woonme/services/app_features_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  BackendUser? _backendUser;
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _isOpeningWeb = false;
  bool _alertsEnabled = false;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadFeatures();
    _loadNotificationStatus();
  }

  Future<void> _loadNotificationStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (mounted) {
      setState(() {
        _notificationsEnabled =
            settings.authorizationStatus == AuthorizationStatus.authorized;
      });
    }
  }

  Future<void> _loadFeatures() async {
    final features = await AppFeaturesService.get();
    if (mounted) setState(() => _alertsEnabled = features.alerts);
  }

  Future<void> _loadUser() async {
    final user = await ApiService.getMe();
    if (mounted) {
      setState(() {
        _backendUser = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _openAccountPage() async {
    setState(() => _isOpeningWeb = true);
    try {
      final lang = Localizations.localeOf(context).languageCode;
      final url = await ApiService.getMagicLink(page: 'account', lang: lang);
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isOpeningWeb = false);
    }
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileDeleteDialogTitle),
        content: Text(l10n.profileDeleteDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.profileDeleteDialogCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.profileDeleteDialogConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await ApiService.deleteAccount();
      await user?.delete();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      return;
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (e.code == 'requires-recent-login') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileErrorRelogin)),
        );
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.profileErrorGeneric(e.message ?? ''))),
        );
        setState(() => _isDeleting = false);
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileErrorDelete('$e'))),
      );
      setState(() => _isDeleting = false);
    }
  }

  String _getInitials(String? name, String email) {
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return name.trim()[0].toUpperCase();
    }
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final locale = Localizations.localeOf(context).languageCode;
      return DateFormat.yMMMMd(locale).format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final displayName =
        firebaseUser?.displayName ?? _backendUser?.displayName;
    final email = firebaseUser?.email ?? _backendUser?.email ?? '';
    final colorScheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profilePageTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // ── Avatar ──────────────────────────────────────────────
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      _getInitials(displayName, email),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (displayName != null && displayName.isNotEmpty) ...[
                  Center(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Center(
                  child: Text(
                    email,
                    style:
                        TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Meer accountopties ──────────────────────────────────
                if (FirebaseAuth.instance.currentUser != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isOpeningWeb ? null : _openAccountPage,
                      icon: _isOpeningWeb
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.open_in_browser),
                      label: Text(l10n.profileMoreOptions),
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // ── Taal ────────────────────────────────────────────────
                Text(
                  l10n.profileLanguageSection,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                        value: 'nl',
                        label: Text(l10n.profileLanguageNl)),
                    ButtonSegment(
                        value: 'en',
                        label: Text(l10n.profileLanguageEn)),
                  ],
                  selected: {lang},
                  onSelectionChanged: (s) =>
                      WoonMeApp.of(context)?.setLocale(Locale(s.first)),
                ),

                const SizedBox(height: 28),

                // ── Notificaties ──────────────────────────────────────
                Text(
                  l10n.profileNotificationsSection,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: SwitchListTile(
                    title: Text(l10n.profileNotificationsReceive),
                    value: _notificationsEnabled,
                    onChanged: (bool value) async {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      if (value) {
                        final messaging = FirebaseMessaging.instance;
                        final settings = await messaging.requestPermission();
                        if (settings.authorizationStatus !=
                            AuthorizationStatus.authorized) {
                          setState(() {
                            _notificationsEnabled = false;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.profileNotificationsEnableInSettings),
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // ── Gegevens ────────────────────────────────────────────
                if (_backendUser != null)
                  Card(
                    child: Column(
                      children: [
                        _infoTile(
                          context,
                          Icons.calendar_today_outlined,
                          l10n.profileMemberSince,
                          _formatDate(_backendUser!.createdAt),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _infoTile(
                          context,
                          Icons.access_time_outlined,
                          l10n.profileLastActivity,
                          _formatDate(_backendUser!.lastSeenAt),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 28),

                // ── Uitloggen ───────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout),
                    label: Text(l10n.profileLogout),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Feedback ────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FeedbackPage(),
                      ),
                    ),
                    icon: const Icon(Icons.feedback_outlined),
                    label: Text(l10n.profileFeedback),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Account verwijderen ─────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isDeleting ? null : _deleteAccount,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete_forever),
                    label: Text(l10n.profileDeleteAccount),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}
