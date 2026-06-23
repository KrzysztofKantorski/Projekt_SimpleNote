import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_state_viewmodel.dart';

class OnboardingView extends StatelessWidget {

  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(Icons.school, size: 120, color: Colors.deepPurple),
            const SizedBox(height: 32),
            const Text(
              'Witaj w Simple Note!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Twórz, skanuj i udostępniaj swoje notatki. Dołącz do społeczności i ucz się mądrzej.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Provider.of<AppStateViewModel>(context, listen: false).completeOnboarding();
                    context.goNamed('login');
                  },
                  child: const Text('Zaczynamy', style: TextStyle(fontSize: 18)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  
}