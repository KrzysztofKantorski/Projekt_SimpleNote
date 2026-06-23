import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/app_state_viewmodel.dart'; 
import 'register_view.dart';
import 'package:simple_note/components/welcome_widgets/welcome_widgets.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}


class _LoginViewState extends State<LoginView>{
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      debugPrint("submit");
      final success = await authViewModel.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (success && mounted) {

        Provider.of<AppStateViewModel>(context, listen: false).loginSuccess();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
        body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              const AppTitle(),
              const SizedBox(height: 40),
              const ScreenHeader(
                title: 'Witaj z powrotem!',
                subtitle: 'Wprowadź nazwę użytkownika i hasło, aby się zalogować',
              ),
              const SizedBox(height: 28),
              CustomFormTextField(
                controller: _usernameController,
                placeholder: 'Nazwa Użytkownika',
                validator: (val) => val == null || val.isEmpty ? 'Podaj login' : null,
              ),
              const SizedBox(height: 16),
              CustomFormTextField(
                controller: _passwordController,
                obscureText: true,
                placeholder: 'Hasło',
                validator: (val) => val == null || val.isEmpty ? 'Podaj hasło' : null,
              ),
              const SizedBox(height: 12),
            
              if (authViewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(authViewModel.errorMessage!, style: const TextStyle(color: Colors.red)),
                ),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: authViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        onPressed: _submit,
                        label: 'Zaloguj się',
                      ),
              ),

              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                  authViewModel.clearError();

                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterView()))
                  .then((_) {
                    // Clear errors
                    authViewModel.clearError();
                  });
                },
                child: const Text('Nie masz konta? Zarejestruj się'),
              )
            ],
          ),
        ),
        ),
      ),
    );
  }
}