// src/pages/ReactionList.tsx
import { useState } from 'react';
import { 
  Box, TableCell, TableRow, CircularProgress, Alert, Dialog, 
  DialogTitle, DialogContent, DialogActions,
  Typography
} from '@mui/material';

import { 
  useReactionsQuery, 
  useDeleteReaction, 
  useCreateReaction, 
  useUpdateReaction 
} from '../hooks/useReactions';
import type { ReactionTypeDto } from '../types/reactionTypes';

// Gotowe komponenty UI
import { AdminPageHeader } from '../components/AdminPageHeader';
import { AdminActionButtons } from '../components/AdminActionButtons';
import { AdminTable } from '../components/AdminTable';
import { AdminInput } from '../components/AdminInput';
import { AdminButton } from '../components/AdminButton';

export const ReactionList = () => {

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingReaction, setEditingReaction] = useState<ReactionTypeDto | null>(null);
  

  const [reactionName, setReactionName] = useState('');
  const [reactionIconUrl, setReactionIconUrl] = useState('');
  const [validationError, setValidationError] = useState('');

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingReaction(null);
    setReactionName('');
    setReactionIconUrl('');
    setValidationError('');
  };

  const { data: reactions, isLoading, isError, error } = useReactionsQuery();
  const deleteMutation = useDeleteReaction();
  const createMutation = useCreateReaction(handleCloseModal);
  const updateMutation = useUpdateReaction(handleCloseModal);

  const handleDelete = (id: number, name: string) => {
    if (window.confirm(`Czy na pewno chcesz usunąć reakcję: ${name}?`)) {
      deleteMutation.mutate(id);
    }
  };

  const handleOpenModal = (reaction?: ReactionTypeDto) => {
    setValidationError('');
    if (reaction) {
      setEditingReaction(reaction);
      setReactionName(reaction.name);
      setReactionIconUrl(reaction.iconUrl);
    } else {
      setEditingReaction(null);
      setReactionName('');
      setReactionIconUrl('');
    }
    setIsModalOpen(true);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    
    const trimmedName = reactionName.trim();
    const trimmedIconUrl = reactionIconUrl.trim();

    if (!trimmedName || !trimmedIconUrl) {
      setValidationError('Wszystkie pola muszą być wypełnione.');
      return;
    }

    const payload = { name: trimmedName, iconUrl: trimmedIconUrl };

    if (editingReaction) {
      updateMutation.mutate({ id: editingReaction.id, data: payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  const isSubmitting = createMutation.isPending || updateMutation.isPending;

  return (
    <Box>
      <AdminPageHeader 
        title="Zarządzanie reakcjami" 
        actionText="Dodaj reakcję" 
        onAction={() => handleOpenModal()} 
      />

      {isLoading && <CircularProgress sx={{ display: 'block', margin: '40px auto' }} />}
      {isError && <Alert severity="error" sx={{ mb: 2 }}>{(error as Error).message}</Alert>}
      {deleteMutation.isError && <Alert severity="error" sx={{ mb: 2 }}>Błąd usuwania: {(deleteMutation.error as Error).message}</Alert>}


      {!isLoading && !isError && reactions && (
        <AdminTable headers={['ID', 'Ikona', 'Nazwa', 'Akcje']}>
          {reactions.length === 0 ? (
            <TableRow>
              <TableCell colSpan={4} align="center" sx={{ py: 3 }}>
                Brak reakcji w bazie. Kliknij "Dodaj reakcję".
              </TableCell>
            </TableRow>
          ) : (
            reactions.map((reaction) => (
              <TableRow key={reaction.id}>
                <TableCell width="10%">{reaction.id}</TableCell>
                <TableCell width="15%">
                 <Typography>{reaction.iconUrl}</Typography>
                </TableCell>
                <TableCell>{reaction.name}</TableCell>
                <TableCell align="right" width="35%">
                  <AdminActionButtons 
                    onEdit={() => handleOpenModal(reaction)} 
                    onDelete={() => handleDelete(reaction.id, reaction.name)} 
                  />
                </TableCell>
              </TableRow>
            ))
          )}
        </AdminTable>
      )}

      <Dialog open={isModalOpen} onClose={handleCloseModal} fullWidth maxWidth="sm">
        <form onSubmit={handleSubmit}>
          <DialogTitle>
            {editingReaction ? 'Edytuj reakcję' : 'Dodaj nową reakcję'}
          </DialogTitle>
          
          <DialogContent>
            {validationError && (
              <Alert severity="warning" sx={{ mb: 2, mt: 1 }}>{validationError}</Alert>
            )}
            {(createMutation.isError || updateMutation.isError) && (
              <Alert severity="error" sx={{ mb: 2, mt: 1 }}>
                {(createMutation.error as Error)?.message || (updateMutation.error as Error)?.message}
              </Alert>
            )}

            <AdminInput
              label="Nazwa reakcji (np. Like, Serce)"
              value={reactionName}
              onChange={(e) => setReactionName(e.target.value)}
              disabled={isSubmitting}
              autoFocus 
            />
            
            <AdminInput
              label="Adres URL ikony (lub emoji)"
              value={reactionIconUrl}
              onChange={(e) => setReactionIconUrl(e.target.value)}
              disabled={isSubmitting}
            />
          </DialogContent>
          
          <DialogActions sx={{ px: 3, pb: 3 }}>
            <AdminButton onClick={handleCloseModal} disabled={isSubmitting} color="inherit">
              Anuluj
            </AdminButton>
            <AdminButton 
              type="submit" 
              disabled={isSubmitting}
              startIcon={isSubmitting ? <CircularProgress size={20} color="inherit" /> : null}
            >
              {isSubmitting ? 'Zapisywanie...' : 'Zapisz'}
            </AdminButton>
          </DialogActions>
        </form>
      </Dialog>
    </Box>
  );
};