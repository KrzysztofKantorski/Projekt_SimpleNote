import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/app_state_viewmodel.dart'; 
import 'register_view.dart';


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
      
      //Send data to viewmodel
      final success = await authViewModel.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (success && mounted) {

        //Navigate to notes view
        Provider.of<AppStateViewModel>(context, listen: false).loginSuccess();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.note_alt, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 32),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Login', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Podaj login' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Hasło', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Podaj hasło' : null,
              ),
              const SizedBox(height: 24),
              

              //Display error message
              if (authViewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(authViewModel.errorMessage!, style: const TextStyle(color: Colors.red)),
                ),

              SizedBox(
                width: double.infinity,
                height: 50,

                //Loading
                child: authViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Zaloguj', style: TextStyle(fontSize: 18)),
                      ),
              ),

              //Navigate to register view
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
    );
  }
}