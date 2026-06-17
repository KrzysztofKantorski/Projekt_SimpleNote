import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


// Services
import 'services/dio_client.dart';

// ViewModels
import 'viewmodels/app_state_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';
import 'viewmodels/note_viewmodel.dart';
import 'viewmodels/comment_viewmodel.dart';
import 'viewmodels/reaction_viewmodel.dart';

// Theme
import 'theme/AppTheme.dart';

// Router
import 'app_router.dart';


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
        ChangeNotifierProvider(create: (_) => NoteViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => CommentViewModel()),
        ChangeNotifierProvider(create: (_) => ReactionViewModel())
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
    return Builder(
      builder: (innerContext){
      final appStateViewModel = Provider.of<AppStateViewModel>(innerContext, listen: false);
      final router = AppRouter.createRouter(appStateViewModel);
      return MaterialApp.router(
        title: 'Simple Note',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: router,
        );
      },
    );
  }
}
