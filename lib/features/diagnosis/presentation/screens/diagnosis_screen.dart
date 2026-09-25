import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:go_router/go_router.dart'; // Descoméntalo si lo usas más adelante

import 'package:muevete/features/diagnosis/presentation/providers/diagnosis_provider.dart';
import 'package:muevete/shared/widgets/my_button_secondarytext.dart';
import 'package:muevete/shared/widgets/my_quiz_image.dart';
import 'package:muevete/features/diagnosis/presentation/widgets/my_quizoption_button.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class DiagnosisScreen extends ConsumerStatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  ConsumerState<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends ConsumerState<DiagnosisScreen>{
  
  String? selectedOption;

  @override
  Widget build(BuildContext context) {

    final diagnosisAsync = ref.watch(diagnosisProvider);
    final notifier = ref.read(diagnosisProvider.notifier);


    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnosis"),
      ),
      body: Center(
        child: diagnosisAsync.when(
          data: (state) {
            final currentQuestion = state.questions[state.currentQuestion];
            final description = currentQuestion.question;
            final options = currentQuestion.options.toList();

            int getSelectedValue (){
              if(selectedOption == null) throw Exception("No option selected");

              final selectedOptionValue = options.firstWhere(
                (opt) => opt.text == selectedOption,
              );

              return selectedOptionValue.value;
            }

            return SingleChildScrollView( // Previene desbordamiento de pantalla si hay muchas opciones
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  
                  children: [                 
                    const SizedBox(height: 20),
                    Text(
                      description,
                
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MyQuizImage(imagePath: currentQuestion.imagePath),
                    const SizedBox(height: 20),
                    
                    // y usar el operador spread (...) para meter los elementos en la Column.
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
                      if (currentQuestion.order >1 )
                        MyButtonSecondarytext(
                          text: 'Previous', 
                          onTap: (){
                            notifier.previousQuestion();
                          }
                        ),
                      
                      MyButtonSecondarytext(
                        text: currentQuestion.order == 5 ? 'Finish' :'Next', 
                        onTap: (){
                          notifier.answer(
                            currentQuestion.id, 
                            getSelectedValue(),
                          );
                          if(currentQuestion.order < 5){
                            setState(() {
                              selectedOption = null;
                            });
                            notifier.nextQuestion();

                          }else {
                          
                            QuickAlert.show(
                              context: context, 
                              type: QuickAlertType.warning,
                              text: 'Are you sure you wanna finish the test?',
                              showCancelBtn: true,
                              barrierDismissible: false,
                              confirmBtnText: 'Finsih',
                              onConfirmBtnTap: () async {
                              try{
                                await notifier.finish();

                                if (!context.mounted) return;
                                await QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.success,
                                  barrierDismissible: false,
                                  text: 'Diagnosis saved Successfully!',
                                  confirmBtnColor: Colors.green,
                                  confirmBtnText: 'Accept'

                                );
                                if (context.mounted) context.go('/home'); 
                                if (context.mounted) context.go('/'); 
                              }catch(e){
                                QuickAlert.show(
                                  context: context,
                                  type: QuickAlertType.error,
                                  title: 'Sorry, something went wrong',
                                  text: 'Error: ${e.toString()}',
                                );
                                if (context.mounted) {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.error,
                                    title: 'Sorry, something went wrong',
                                    text: 'Error: ${e.toString()}',
                                  );
                                }
                              }
                              }
                            );
                          }
                        }
                      ),  
                    ],
                  ),
                  
                  ],
                ),
              ),
            );
          },
          error: (error, stackTrace) => Text("Error: $error"), 
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}