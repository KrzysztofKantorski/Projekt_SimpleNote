import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';


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


  //Form submit - validate data and send to viewmodel
  Future<void> _submit() async {

    //Validation
    if (_formKey.currentState!.validate()) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      
      //Send data to viewmodel
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
    //Observe changes
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Rejestracja')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Icon(Icons.app_registration, size: 80, color: Colors.deepPurple),
              const SizedBox(height: 32),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Nazwa użytkownika', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Wpisz nazwę użytkownika' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Hasło', border: OutlineInputBorder()),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wpisz hasło';
                  if (val.length < 8) return 'Hasło musi mieć min. 8 znaków';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Display error messages from backend
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

                //Loading
                child: authViewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Zarejestruj się', style: TextStyle(fontSize: 18)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}