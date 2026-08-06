import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muevete/features/auth/presentation/providers/auth_provider.dart';
import 'package:muevete/shared/widgets/my_button.dart';
import 'package:muevete/shared/widgets/my_button_secondarytext.dart';
import 'package:muevete/shared/widgets/my_heading_two.dart';
import 'package:muevete/shared/widgets/my_textinputfield.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String? errorMessage = '';
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void handleLogin() async{
    if(_email.text.isEmpty || _password.text.isEmpty){
      setState(() {
        errorMessage = "Email or password cannot be empty";
      });
      return;
    }else if(_password.text.length <6){
      setState(() {
        errorMessage = "Password must be at least 6 characters long";
      });
      return;
    }else if(!_email.text.contains('@')){
      setState(() {
        errorMessage = "Email is not valid";
      });
      return;
    }
    setState(() {
        errorMessage = "";
    });
    try{
      await ref.read(authProvider.notifier).signIn(
        email: _email.text, 
        password: _password.text,
      );
    }on FirebaseAuthException catch(e){
      setState(() {
        errorMessage = e.toString();
      });
      return;
    }
  }


  @override
  Widget build(BuildContext context) { // Nota: Aquí ya no se necesita pasar 'WidgetRef ref' por parámetro, se usa 'ref' directamente
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyHeadingTwo(text: "Login"),
            const SizedBox(height: 20),
            
            if (errorMessage != null && errorMessage!.isNotEmpty)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              
            const SizedBox(height: 40),

            MyTextinputfield(
              controller: _email,
              hintText: "example@gmail.com",
              obscureText: false, // Cambiado a false para el correo
            ),
            const SizedBox(height: 30),

            MyTextinputfield(
              controller: _password,
              hintText: "....",
              obscureText: true,
            ),
            const SizedBox(height: 30),

            MyButton(
              text: "Enter",
              onTap: handleLogin, // Llamamos a tu función modificada
            ),
            const SizedBox(height: 15),

            MyButtonSecondarytext(
              text: "Create a new account",
              onTap: () => context.go("/signup"),
            ),
          ],
        ),
      ),
    );
  }
}