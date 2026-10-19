import 'package:flutter/material.dart';
import 'package:muevete/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/diagnosis/presentation/providers/diagnosis_provider.dart';
import 'package:muevete/features/diagnosis/presentation/widgets/my_quizoption_button.dart';
import 'package:muevete/shared/widgets/my_button_secondarytext.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final diagnosisAsync = ref.watch(diagnosisProvider);
    final notifier = ref.read(diagnosisProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.diagTitle)),
      body: Center(
        child: diagnosisAsync.when(
          data: (state) {
            final currentQuestion = state.questions[state.currentQuestion];
            final description = currentQuestion.question;
            final options = currentQuestion.options.toList();

            int getSelectedValue() {
              if (selectedOption == null) throw Exception("No option selected");

              final selectedOptionValue = options.firstWhere(
                (opt) => opt.text == selectedOption,
              );

              return selectedOptionValue.value;
            }

            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MyQuizImage(imagePath: currentQuestion.imagePath),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (currentQuestion.order > 1)
                          MyButtonSecondarytext(
                            text: l10n.diagPrevious,
                            onTap: () {
                              notifier.previousQuestion();
                            },
                          ),
                        MyButtonSecondarytext(
                          text: currentQuestion.order == 5
                              ? l10n.diagFinish
                              : l10n.diagNext,
                          onTap: () {
                            notifier.answer(
                              currentQuestion.id,
                              getSelectedValue(),
                            );
                            if (currentQuestion.order < 5) {
                              setState(() {
                                selectedOption = null;
                              });
                              notifier.nextQuestion();
                            } else {
                              final navigator = Navigator.of(
                                context,
                                rootNavigator: true,
                              );
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
                                    confirmBtnColor: Colors.green,
                                    confirmBtnText: l10n.diagAccept,
                                  );
                                  router.go('/');
                                },
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          error: (error, stackTrace) => Text(l10n.errGeneric(error.toString())),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
