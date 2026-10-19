import 'package:flutter/material.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/active_breaks/domain/entities/active_break.dart';
import 'package:muevete/features/active_breaks/presentation/providers/active_break_providers.dart';
import 'package:muevete/features/localization/domain/localized_map_extension.dart';
import 'package:muevete/features/localization/presentation/widgets/locale_switcher.dart';

class ActiveBreakSelectionScreen extends ConsumerWidget {
  const ActiveBreakSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final activeBreaks = ref.watch(activeBreaksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.abChooseTitle),
        actions: const [
          LocaleSwitcher(compact: true),
          SizedBox(width: 8),
        ],
      ),
      body: activeBreaks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _Message(
          text: l10n.abCouldNotLoad,
          action: TextButton(
            onPressed: () => ref.invalidate(activeBreaksProvider),
            child: Text(l10n.notifRetry),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return _Message(text: l10n.abNoAvailable);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) =>
                _ActiveBreakTile(activeBreak: items[index]),
          );
        },
      ),
      floatingActionButton: activeBreaks.asData?.value.isNotEmpty == true
          ? FloatingActionButton.extended(
              onPressed: () {
                final selected =
                    chooseRandomActiveBreak(activeBreaks.requireValue);
                context.push('/active-breaks/workout', extra: selected);
              },
              icon: const Icon(Icons.casino_outlined),
              label: Text(l10n.abChooseRandom),
            )
          : null,
    );
  }
}

class _ActiveBreakTile extends StatelessWidget {
  const _ActiveBreakTile({required this.activeBreak});

  final ActiveBreak activeBreak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = activeBreak.name.localized(context, fallback: 'Active Break');
    final desc = activeBreak.description.localized(context, fallback: '');
    final durationStr = l10n.abDurationMinutes(activeBreak.durationMinutes);

    return Card(
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(desc.isNotEmpty ? '$desc\n$durationStr' : durationStr),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () =>
            context.push('/active-breaks/workout', extra: activeBreak),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text(text), if (action != null) action!],
      ),
    );
  }
}
