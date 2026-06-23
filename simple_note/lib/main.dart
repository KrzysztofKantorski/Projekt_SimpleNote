import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

// Infrastruktura
import 'services/dio_client.dart';

// Serwisy
import 'services/auth_service.dart';
import 'services/note_service.dart';
import 'services/comment_service.dart';
import 'services/community_service.dart';
import 'services/reaction_service.dart';
import 'services/saved_note_service.dart';
import 'services/user_service.dart';

// Repozytoria
import 'repositories/auth_repository.dart';
import 'repositories/note_repository.dart';
import 'repositories/comment_repository.dart';
import 'repositories/community_repository.dart';
import 'repositories/reaction_repository.dart';
import 'repositories/saved_note_repository.dart';
import 'repositories/user_repository.dart';

// ViewModele
import 'viewmodels/app_state_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/note_viewmodel.dart';
import 'viewmodels/comment_viewmodel.dart';
import 'viewmodels/reaction_viewmodel.dart';
import 'viewmodels/community_viewmodel.dart';
import 'viewmodels/saved_note_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';

// Theme i Router
import 'theme/AppTheme.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dioClient = DioClient();
  await dioClient.init();
  final Dio dio = dioClient.dio;

  runApp(
    MultiProvider(
      providers: [
        Provider<Dio>.value(value: dio),

        ProxyProvider<Dio, AuthService>(
          update: (_, dio, _) => AuthService(dio: dio),
        ),
        ProxyProvider<Dio, NoteService>(
          update: (_, dio, _) => NoteService(dio: dio),
        ),
        ProxyProvider<Dio, CommentService>(
          update: (_, dio, _) => CommentService(dio: dio),
        ),
        ProxyProvider<Dio, CommunityService>(
          update: (_, dio, _) => CommunityService(dio: dio),
        ),
        ProxyProvider<Dio, ReactionService>(
          update: (_, dio, _) => ReactionService(dio: dio),
        ),
        ProxyProvider<Dio, SavedNoteService>(
          update: (_, dio, _) => SavedNoteService(dio: dio),
        ),
        ProxyProvider<Dio, UserService>(
          update: (_, dio, _) => UserService(dio: dio),
        ),

        ProxyProvider<AuthService, AuthRepository>(
          update: (_, svc, _) => AuthRepositoryImpl(authService: svc),
        ),
        ProxyProvider<NoteService, NoteRepository>(
          update: (_, svc, _) => NoteRepositoryImpl(noteService: svc),
        ),
        ProxyProvider<CommentService, CommentRepository>(
          update: (_, svc, _) => CommentRepositoryImpl(commentService: svc),
        ),
        ProxyProvider<CommunityService, CommunityRepository>(
          update: (_, svc, _) => CommunityRepositoryImpl(communityService: svc),
        ),
        ProxyProvider<ReactionService, ReactionRepository>(
          update: (_, svc, _) => ReactionRepositoryImpl(reactionService: svc),
        ),
        ProxyProvider<SavedNoteService, SavedNoteRepository>(
          update: (_, svc, _) => SavedNoteRepositoryImpl(savedNoteService: svc),
        ),
        ProxyProvider<UserService, UserRepository>(
          update: (_, svc, _) => UserRepositoryImpl(userService: svc),
        ),

        ChangeNotifierProvider(create: (_) => AppStateViewModel()),

        ChangeNotifierProxyProvider<AuthRepository, AuthViewModel>(
          create: (ctx) => AuthViewModel(repository: ctx.read<AuthRepository>()),
          update: (_, repo, prev) => prev ?? AuthViewModel(repository: repo),
        ),
        ChangeNotifierProxyProvider<NoteRepository, NoteViewModel>(
          create: (ctx) => NoteViewModel(repository: ctx.read<NoteRepository>()),
          update: (_, repo, prev) => prev ?? NoteViewModel(repository: repo),
        ),
        ChangeNotifierProxyProvider<CommentRepository, CommentViewModel>(
          create: (ctx) => CommentViewModel(repository: ctx.read<CommentRepository>()),
          update: (_, repo, prev) => prev ?? CommentViewModel(repository: repo),
        ),
        ChangeNotifierProxyProvider<CommunityRepository, CommunityViewModel>(
          create: (ctx) => CommunityViewModel(repository: ctx.read<CommunityRepository>()),
          update: (_, repo, prev) => prev ?? CommunityViewModel(repository: repo),
        ),
        ChangeNotifierProxyProvider<ReactionRepository, ReactionViewModel>(
          create: (ctx) => ReactionViewModel(repository: ctx.read<ReactionRepository>()),
          update: (_, repo, prev) => prev ?? ReactionViewModel(repository: repo),
        ),
        ChangeNotifierProxyProvider<SavedNoteRepository, SavedNoteViewModel>(
          create: (ctx) => SavedNoteViewModel(repository: ctx.read<SavedNoteRepository>()),
          update: (_, repo, prev) => prev ?? SavedNoteViewModel(repository: repo),
        ),
        ChangeNotifierProxyProvider<UserRepository, UserViewModel>(
          create: (ctx) => UserViewModel(repository: ctx.read<UserRepository>()),
          update: (_, repo, prev) => prev ?? UserViewModel(repository: repo),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appStateViewModel =
        Provider.of<AppStateViewModel>(context, listen: false);
    final router = AppRouter.createRouter(appStateViewModel);

    return MaterialApp.router(
      title: 'Simple Note',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}