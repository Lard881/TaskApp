import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/preferences_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';

class TimeZoneSelectionScreen extends ConsumerStatefulWidget {
  const TimeZoneSelectionScreen({super.key});

  @override
  ConsumerState<TimeZoneSelectionScreen> createState() =>
      _TimeZoneSelectionScreenState();
}

class _TimeZoneSelectionScreenState
    extends ConsumerState<TimeZoneSelectionScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  static const List<_TZ> _allZones = [
    _TZ('local', 'Device Default'),
    _TZ('UTC', 'UTC'),
    _TZ('America/New_York', 'Eastern Time (US & Canada)'),
    _TZ('America/Chicago', 'Central Time (US & Canada)'),
    _TZ('America/Denver', 'Mountain Time (US & Canada)'),
    _TZ('America/Los_Angeles', 'Pacific Time (US & Canada)'),
    _TZ('America/Anchorage', 'Alaska'),
    _TZ('Pacific/Honolulu', 'Hawaii'),
    _TZ('America/Sao_Paulo', 'Brasilia'),
    _TZ('America/Toronto', 'Toronto'),
    _TZ('America/Mexico_City', 'Mexico City'),
    _TZ('Europe/London', 'London'),
    _TZ('Europe/Paris', 'Paris'),
    _TZ('Europe/Berlin', 'Berlin'),
    _TZ('Europe/Madrid', 'Madrid'),
    _TZ('Europe/Rome', 'Rome'),
    _TZ('Europe/Moscow', 'Moscow'),
    _TZ('Europe/Istanbul', 'Istanbul'),
    _TZ('Africa/Cairo', 'Cairo'),
    _TZ('Africa/Johannesburg', 'Johannesburg'),
    _TZ('Africa/Lagos', 'Lagos'),
    _TZ('Asia/Dubai', 'Dubai'),
    _TZ('Asia/Karachi', 'Karachi'),
    _TZ('Asia/Kolkata', 'Mumbai, Kolkata'),
    _TZ('Asia/Dhaka', 'Dhaka'),
    _TZ('Asia/Bangkok', 'Bangkok'),
    _TZ('Asia/Singapore', 'Singapore'),
    _TZ('Asia/Shanghai', 'Beijing, Shanghai'),
    _TZ('Asia/Tokyo', 'Tokyo'),
    _TZ('Asia/Seoul', 'Seoul'),
    _TZ('Australia/Sydney', 'Sydney'),
    _TZ('Australia/Melbourne', 'Melbourne'),
    _TZ('Pacific/Auckland', 'Auckland'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(preferencesProvider).valueOrNull;
    final currentTz = prefs?.timeZoneId ?? 'local';
    final filtered = _query.isEmpty
        ? _allZones
        : _allZones
            .where((z) =>
                z.id.toLowerCase().contains(_query) ||
                z.label.toLowerCase().contains(_query))
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.timeZone)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.spaceM),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search time zones…',
                prefixIcon: Icon(BootstrapIcons.search),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: AppSizes.spaceM),
              itemBuilder: (_, i) {
                final tz = filtered[i];
                final isSelected = tz.id == currentTz;
                return Semantics(
                  label: '${tz.label}${isSelected ? ", selected" : ""}',
                  button: true,
                  child: ListTile(
                    title: Text(tz.label,
                        style: const TextStyle(
                            fontSize: AppSizes.fontBody,
                            fontWeight: FontWeight.w500)),
                    subtitle: Text(tz.id,
                        style: TextStyle(
                            fontSize: AppSizes.fontSmall,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.55))),
                    trailing: isSelected
                        ? const Icon(BootstrapIcons.check2,
                            color: AppColors.primary)
                        : null,
                    onTap: () async {
                      await ref
                          .read(preferencesProvider.notifier)
                          .setTimeZone(tz.id);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spaceM,
                        vertical: AppSizes.spaceXS),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TZ {
  const _TZ(this.id, this.label);
  final String id;
  final String label;
}
