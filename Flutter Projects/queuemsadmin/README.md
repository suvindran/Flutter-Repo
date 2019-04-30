# queuemsadmin

A new Flutter project.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

Rebuilding l10n/messages_all.dart requires two steps.
1. With the app’s root directory as the current directory, generate l10n/intl_messages.arb from lib/localizations.dart:
flutter packages pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/localizations.dart
2. With the app’s root directory as the current directory, generate intl_messages_<locale>.dart for each intl_<locale>.arb file and intl_messages_all.dart, which imports all of the messages files:
flutter packages pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/localizations.dart lib/l10n/intl_*.arb

flutter packages pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/localizations.dart lib/l10n/intl_en.arb lib/l10n/intl_pt.arb lib/l10n/intl_zh.arb 
