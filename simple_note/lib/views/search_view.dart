import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_note/viewmodels/note_viewmodel.dart';
import '../components/menu_widgets/menu_widgets.dart';
import '../components/other_widgets/other_widgets.dart';

class SearchNotesView extends StatelessWidget {
  const SearchNotesView({super.key});

  @override
  Widget build(BuildContext context) {
    final ViewModel = Provider.of<NoteViewModel>(context, listen: false);
    return ChangeNotifierProvider.value(
      value: ViewModel,
      child: const _SearchBody(),
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NoteViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // — Pasek wyszukiwania —
            SnSearchBar(
              onChanged: (q) => viewModel.search(q), 
              onBack: () {
                Navigator.pop(context);
                viewModel.search('');
                },
            ),

            // — Wyniki —
            Expanded(
              child: _buildContent(context, viewModel),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SnBottomNavBar(
        currentIndex: 0, 
        onTap: (index) {
          if (index == 0) Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, NoteViewModel viewModel) {
    // Stan: ładowanie
    if (viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (viewModel.query.trim().isEmpty) {
      return const Center(
        child: Text(
          'Wpisz frazę, aby wyszukać notatki',
          style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
        ),
      );
    }

    if (viewModel.results.isEmpty) {
      return const Center(
        child: Text(
          'Brak notatek dla tego hasła',
          style: TextStyle(color: Color(0xFF888888), fontSize: 14),
        ),
      );
    }

    // Lista wyników
    return ListView.builder(
      itemCount: viewModel.results.length,
      itemBuilder: (_, i) => SnSearchResultItem(
        note: viewModel.results[i],
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => NotePreviewScreen(note: viewModel.results[i]),
          //   ),
          // );
        },
      ),
    );
  }
}