import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/active_breaks/domain/entities/active_break.dart';
import 'package:muevete/features/active_breaks/presentation/providers/active_break_providers.dart';

class ActiveBreakSelectionScreen extends ConsumerWidget {
  const ActiveBreakSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBreaks = ref.watch(activeBreaksProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Choose an Active Break')),
      body: activeBreaks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _Message(
          text: 'Could not load Active Breaks.',
          action: TextButton(
            onPressed: () => ref.invalidate(activeBreaksProvider),
            child: const Text('Retry'),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const _Message(text: 'No Active Breaks are available right now.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) => _ActiveBreakTile(activeBreak: items[index]),
          );
        },
      ),
      floatingActionButton: activeBreaks.asData?.value.isNotEmpty == true
          ? FloatingActionButton.extended(
              onPressed: () {
                final selected = chooseRandomActiveBreak(activeBreaks.requireValue);
                context.push('/active-breaks/workout', extra: selected);
              },
              icon: const Icon(Icons.casino_outlined),
              label: const Text('Choose randomly'),
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
    return Card(
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(activeBreak.name['en'] ?? 'Active Break'),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('${activeBreak.description['en'] ?? ''}\n${activeBreak.durationMinutes} minutes'),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () => context.push('/active-breaks/workout', extra: activeBreak),
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
