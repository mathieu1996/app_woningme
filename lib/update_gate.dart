import 'package:flutter/material.dart';
import 'package:woonme/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:woonme/services/update_check_service.dart';
import 'package:woonme/widgets/splash_screen.dart';

class UpdateGate extends StatefulWidget {
  final Widget child;

  const UpdateGate({super.key, required this.child});

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  _Status _status = _Status.loading;
  String? _storeUrl;

  @override
  void initState() {
    super.initState();
    _runCheck();
  }

  Future<void> _runCheck() async {
    final config = await UpdateCheckService.check();
    if (!mounted) return;
    setState(() {
      switch (config.mode) {
        case UpdateMode.enforce:
          _status = _Status.enforce;
          _storeUrl = config.storeUrl;
        case UpdateMode.prompt:
          _status = _Status.prompt;
          _storeUrl = config.storeUrl;
        case UpdateMode.none:
          _status = _Status.upToDate;
      }
    });

    if (_status == _Status.prompt) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _showPromptDialog());
    }
  }

  Future<void> _openStore() async {
    if (_storeUrl == null) return;
    final uri = Uri.parse(_storeUrl!);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showPromptDialog() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.updatePromptTitle),
        content: Text(l10n.updatePromptBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.updatePromptLater),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _openStore();
            },
            child: Text(l10n.updatePromptUpdate),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case _Status.loading:
        return const SplashScreen();

      case _Status.enforce:
        return _EnforceScreen(onUpdate: _openStore);

      case _Status.upToDate:
      case _Status.prompt:
        return widget.child;
    }
  }
}

enum _Status { loading, upToDate, enforce, prompt }

class _EnforceScreen extends StatelessWidget {
  final VoidCallback onUpdate;

  const _EnforceScreen({required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.system_update_alt,
                      size: 80, color: colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    l10n.updateEnforceTitle,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.updateEnforceBody,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: onUpdate,
                      child: Text(l10n.updateEnforceButton),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
