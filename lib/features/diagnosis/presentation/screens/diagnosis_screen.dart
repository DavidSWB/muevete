import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/diagnosis/domain/entities/question.dart';
import 'package:muevete/features/diagnosis/presentation/providers/diagnosis_provider.dart';
import 'package:muevete/features/diagnosis/presentation/widgets/my_quizoption_button.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:muevete/shared/theme/app_colors.dart';
import 'package:muevete/shared/widgets/my_quiz_image.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class DiagnosisScreen extends ConsumerStatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  ConsumerState<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends ConsumerState<DiagnosisScreen> {
  String? selectedOption;

  void _handleNextOrFinish({
    required BuildContext context,
    required DiagnosisNotifier notifier,
    required Question currentQuestion,
    required int totalQuestions,
    required int selectedValue,
    required AppLocalizations l10n,
  }) {
    notifier.answer(currentQuestion.id, selectedValue);

    final isLastQuestion = currentQuestion.order >= totalQuestions;
    if (!isLastQuestion) {
      setState(() {
        selectedOption = null;
      });
      notifier.nextQuestion();
      return;
    }

    final navigator = Navigator.of(context, rootNavigator: true);
    final router = GoRouter.of(context);

    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      text: l10n.diagConfirmFinish,
      showCancelBtn: true,
      barrierDismissible: false,
      confirmBtnText: l10n.diagFinish,
      onConfirmBtnTap: () async {
        try {
          await notifier.finish();
        } catch (e) {
          if (!navigator.mounted) return;
          navigator.pop();
          await QuickAlert.show(
            context: navigator.context,
            type: QuickAlertType.error,
            title: l10n.diagSomethingWentWrong,
            text: l10n.errGeneric(e.toString()),
          );
          return;
        }

        if (!navigator.mounted) return;
        navigator.pop();
        await QuickAlert.show(
          context: navigator.context,
          type: QuickAlertType.success,
          barrierDismissible: false,
          text: l10n.diagSavedSuccess,
          confirmBtnColor: AppColors.success,
          confirmBtnText: l10n.diagAccept,
        );
        router.go('/');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final diagnosisAsync = ref.watch(diagnosisProvider);
    final notifier = ref.read(diagnosisProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(l10n.diagTitle),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: diagnosisAsync.when(
        data: (state) {
          final totalQuestions = state.questions.length;
          final currentIndex = state.currentQuestion;
          final currentQuestion = state.questions[currentIndex];
          final description = currentQuestion.question;
          final options = currentQuestion.options.toList();
          final progress = totalQuestions > 0
              ? (currentIndex + 1) / totalQuestions
              : 0.0;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${currentIndex + 1} / $totalQuestions',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.softGrey,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  MyQuizImage(imagePath: currentQuestion.imagePath),
                  const SizedBox(height: 24),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...options.map((option) {
                    return MyQuizoptionButton(
                      text: option.text,
                      isSelected: selectedOption == option.text,
                      onTap: () {
                        setState(() {
                          selectedOption = option.text;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          );
        },
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.errGeneric(error.toString())),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryDark),
        ),
      ),
      bottomNavigationBar: diagnosisAsync.whenOrNull(
        data: (state) {
          final totalQuestions = state.questions.length;
          final currentQuestion = state.questions[state.currentQuestion];
          final options = currentQuestion.options.toList();
          final isLastQuestion = currentQuestion.order >= totalQuestions &&
              totalQuestions >= 5 ||
              currentQuestion.order == 5;

          int getSelectedValue() {
            if (selectedOption == null) throw Exception('No option selected');
            final selectedOptionValue = options.firstWhere(
              (opt) => opt.text == selectedOption,
            );
            return selectedOptionValue.value;
          }

          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Row(
                children: [
                  if (currentQuestion.order > 1) ...[
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        key: const ValueKey('diagnosis-previous-button'),
                        onPressed: () {
                          notifier.previousQuestion();
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: const BorderSide(color: AppColors.primaryDark),
                          foregroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: Text(l10n.diagPrevious),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        key: const ValueKey('diagnosis-next-button'),
                        onPressed: selectedOption == null
                            ? null
                            : () => _handleNextOrFinish(
                                  context: context,
                                  notifier: notifier,
                                  currentQuestion: currentQuestion,
                                  totalQuestions:
                                      totalQuestions < 5 ? 5 : totalQuestions,
                                  selectedValue: getSelectedValue(),
                                  l10n: l10n,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.disabledBg,
                          disabledForegroundColor: AppColors.disabledFg,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isLastQuestion ? l10n.diagFinish : l10n.diagNext,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
