import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_note/viewmodels/auth_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../viewmodels/app_state_viewmodel.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}


class _HomeViewState extends State<HomeView>{

  @override
  void initState() {
    super.initState();
    // Od razu po wyrenderowaniu widoku zlecamy pobranie profilu.
    // listen: false jest tu wymagane, bo jesteśmy w funkcji inicjalizującej.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserViewModel>(context, listen: false).fetchCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje Notatki'),
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              //Dalete token
              await Provider.of<AuthViewModel>(context, listen: false).logout();
              
              //Delete data from view
              Provider.of<UserViewModel>(context, listen: false).clearUser();
              
              //Navigate to login
              Provider.of<AppStateViewModel>(context, listen: false).logoutSuccess();
            },
            tooltip: 'Wyloguj',
          ),
        ],
      ),
      body: Center(
        child: _buildBodyContent(userViewModel),
      ),
    );
  }


  Widget _buildBodyContent(UserViewModel viewModel){
    if (viewModel.isLoading) {
      return const CircularProgressIndicator();
    }

    if (viewModel.errorMessage != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Błąd: ${viewModel.errorMessage}',
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => viewModel.fetchCurrentUser(),
            child: const Text('Spróbuj ponownie'),
          )
        ],
      );
    }


    if (viewModel.user != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 16),
          const Text('Zalogowano pomyślnie!', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            viewModel.user!.username,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Rola: ${viewModel.user!.role}',
              style: TextStyle(color: Colors.deepPurple.shade800, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    }

    return const Text('Brak danych do wyświetlenia');
  }
}