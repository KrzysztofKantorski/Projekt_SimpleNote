import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'package:simple_note/components/welcome_widgets/welcome_widgets.dart';


class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}


class _RegisterViewState extends State<RegisterView>{
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();


  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> _submit() async {

    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      
      final success = await authViewModel.register(
        _usernameController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rejestracja pomyślna. Zaloguj się.')),
        );
        Navigator.pop(context); 
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              const AppTitle(),
              const SizedBox(height: 40),
              const ScreenHeader(
                title: 'Załóż konto',
              ),
              const SizedBox(height: 28),
              CustomFormTextField(
                controller: _usernameController,
                placeholder: 'Nazwa Użytkownika',
                validator: (val) => val == null || val.isEmpty ? 'Wpisz nazwę użytkownika' : null,
              ),
              const SizedBox(height: 12),
              CustomFormTextField(
                controller: _passwordController,
                obscureText: true,
                placeholder: 'Hasło',
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wpisz hasło';
                  if (val.length < 8) return 'Hasło musi mieć min. 8 znaków';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              
              if (authViewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    authViewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 50,

                child: authViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PrimaryButton(
                        onPressed: _submit,
                        label: 'Załóż',
                      ),
                      
              ),
              const SizedBox(height: 16),
              CastomTermsFooter(
                onTermsTap: () {/* TODO */},
                onPrivacyTap: () {/* TODO */},
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
      ),
    );
  }
}