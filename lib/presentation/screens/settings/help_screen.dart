import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:planpal/core/constants/app_sizes.dart';
import 'package:planpal/core/constants/app_strings.dart';
import 'package:planpal/presentation/widgets/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'How do I add a new task?',
      answer: 'Tap the + button on the Tasks screen or use the New Task quick action on the Home screen.',
    ),
    _FaqItem(
      question: 'How do I mark a task as complete?',
      answer: 'Long-press any task and choose "Mark Complete", or open the task detail and tap the button.',
    ),
    _FaqItem(
      question: 'Can I change the app theme?',
      answer: 'Yes. Go to Settings → Interface Theme and choose Light, Dark, or System Default.',
    ),
    _FaqItem(
      question: 'How do I edit my profile?',
      answer: 'Go to Profile → Edit Profile Settings, update your details, and tap Save.',
    ),
    _FaqItem(
      question: 'How do I delete a task?',
      answer: 'Swipe a task to the left to reveal the delete button, or long-press and choose Delete.',
    ),
    _FaqItem(
      question: 'Why are some tasks shown in red?',
      answer: 'Tasks with a red due date are overdue — their due date has passed and they are not yet complete.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.helpSupport)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.spaceM),
        children: [
          Text('Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSizes.spaceM),

          ..._faqs.map((faq) => ExpansionTile(
                title: Text(faq.question,
                    style: const TextStyle(
                        fontSize: AppSizes.fontBody,
                        fontWeight: FontWeight.w500)),
                childrenPadding: const EdgeInsets.fromLTRB(
                    AppSizes.spaceM, 0, AppSizes.spaceM, AppSizes.spaceM),
                children: [
                  Text(faq.answer,
                      style: TextStyle(
                          fontSize: AppSizes.fontBody,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7))),
                ],
              )),

          const SizedBox(height: AppSizes.spaceL),
          const Divider(),
          const SizedBox(height: AppSizes.spaceM),

          SizedBox(
            height: AppSizes.minTouchTarget,
            child: ElevatedButton.icon(
              icon: const Icon(BootstrapIcons.envelope),
              label: const Text(AppStrings.contactSupport),
              onPressed: () => _contactSupport(context),
            ),
          ),
          const SizedBox(height: AppSizes.spaceXL),
        ],
      ),
    );
  }

  Future<void> _contactSupport(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppStrings.supportEmail,
      queryParameters: {'subject': 'PlanPal Support Request'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        AppSnackbar.show(context, AppStrings.noEmailApp, isError: true);
      }
    }
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}
