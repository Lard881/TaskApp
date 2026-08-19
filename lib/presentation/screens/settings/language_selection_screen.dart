import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planpal/application/notifiers/preferences_notifier.dart';
import 'package:planpal/core/constants/app_colors.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  static const List<_Language> _languages = [
    _Language(code: 'en', name: 'English', nativeName: 'English'),
    _Language(code: 'es', name: 'Spanish', nativeName: 'Español'),
    _Language(code: 'fr', name: 'French', nativeName: 'Français'),
    _Language(code: 'de', name: 'German', nativeName: 'Deutsch'),
    _Language(code: 'pt', name: 'Portuguese', nativeName: 'Português'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider).valueOrNull;
    final currentCode = prefs?.languageCode ?? 'en';

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appLanguage)),
      body: ListView.separated(
        itemCount: _languages.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: AppSizes.spaceM),
        itemBuilder: (_, i) {
          final lang = _languages[i];
          final isSelected = lang.code == currentCode;
          return Semantics(
            label: '${lang.name}${isSelected ? ", selected" : ""}',
            button: true,
            child: ListTile(
              title: Text(lang.name,
                  style: const TextStyle(
                      fontSize: AppSizes.fontBody,
                      fontWeight: FontWeight.w500)),
              subtitle: Text(lang.nativeName,
                  style: TextStyle(
                      fontSize: AppSizes.fontSmall,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.55))),
              trailing: isSelected
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () async {
                await ref
                    .read(preferencesProvider.notifier)
                    .setLanguage(lang.code);
                if (context.mounted) Navigator.of(context).pop();
              },
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spaceM, vertical: AppSizes.spaceXS),
            ),
          );
        },
      ),
    );
  }
}

class _Language {
  const _Language(
      {required this.code, required this.name, required this.nativeName});
  final String code;
  final String name;
  final String nativeName;
}
