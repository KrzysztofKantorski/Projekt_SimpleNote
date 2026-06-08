import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services
import 'services/dio_client.dart';

// ViewModels
import 'viewmodels/app_state_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';

// Views
import 'views/onboarding_view.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';






void main() async {
  // For async operations
  WidgetsFlutterBinding.ensureInitialized();
  
  //Initialize dio
  await DioClient().init();

  //Providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Note',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Consumer<AppStateViewModel>(
        builder: (context, appState, child) {

          //Adjust view to app state
          switch (appState.currentState) {

            //App is loading data
            case AppState.loading:
              // Loading screen
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            
            //First app run
            case AppState.onboarding:
              return const OnboardingView();
            
            //User is not logged in
            case AppState.unauthenticated:
              return const LoginView();
            
            //User is logged in
            case AppState.authenticated:
              return const HomeView(); 
          }
        },
      ),


    );
  }


  
}
