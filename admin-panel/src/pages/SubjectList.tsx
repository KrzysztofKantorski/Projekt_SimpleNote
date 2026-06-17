import { useState } from 'react';
import { 
  Box, TableCell, TableRow,
  CircularProgress, Alert, Dialog, DialogTitle, 
  DialogContent, DialogActions
} from '@mui/material';

import type { SubjectDto } from '../types/subjectTypes';

import { AdminPageHeader } from '../components/AdminPageHeader';
import { AdminActionButtons } from '../components/AdminActionButtons';
import { AdminTable } from '../components/AdminTable';
import { AdminInput } from '../components/AdminInput';
import { AdminButton } from '../components/AdminButton';

import { 
  useSubjectsQuery, 
  useDeleteSubject, 
  useCreateSubject, 
  useUpdateSubject 
} from '../hooks/useSubjects';

export const SubjectList = () => {

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingSubject, setEditingSubject] = useState<SubjectDto | null>(null);
  const [subjectName, setSubjectName] = useState('');
  const [validationError, setValidationError] = useState('');

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingSubject(null);
    setSubjectName('');
    setValidationError('');
  };

  const { data: subjects, isLoading, isError, error } = useSubjectsQuery();
  
  const deleteMutation = useDeleteSubject();
  const createMutation = useCreateSubject(handleCloseModal);
  const updateMutation = useUpdateSubject(handleCloseModal);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    const trimmedName = subjectName.trim();
    if (!trimmedName) {
      setValidationError('Nazwa przedmiotu nie może być pusta.');
      return;
    }

    if (editingSubject) {
      updateMutation.mutate({ id: editingSubject.id, data: { name: trimmedName } });
    } else {
      createMutation.mutate({ name: trimmedName });
    }
  };

  const handleDelete = (id: number, name: string) => {
    if (window.confirm(`Czy na pewno chcesz usunąć przedmiot: ${name}?`)) {
      deleteMutation.mutate(id);
    }
  };

  const handleOpenModal = (subject?: SubjectDto) => {
    setValidationError('');
    if (subject) {
      setEditingSubject(subject);
      setSubjectName(subject.name);
    } else {
      setEditingSubject(null);
      setSubjectName('');
    }
    setIsModalOpen(true);
  };

  const isSubmitting = createMutation.isPending || updateMutation.isPending;

  return (
    <Box>
      <AdminPageHeader 
        title="Zarządzanie przedmiotami" 
        actionText="Dodaj przedmiot" 
        onAction={() => handleOpenModal()} 
      />

      {isLoading && <CircularProgress sx={{ display: 'block', margin: '40px auto' }} />}
      {isError && 
        <Alert severity="error" sx={{ mb: 2 }}>
            {(error as Error).message}
        </Alert>}
      {deleteMutation.isError && 
        <Alert severity="error" sx={{ mb: 2 }}>
            Błąd usuwania: {(deleteMutation.error as Error).message}
        </Alert>}

      {!isLoading && !isError && subjects && (
        <AdminTable headers={['ID', 'Nazwa przedmiotu', 'Akcje']}>
          {subjects.length === 0 ? (
            <TableRow>
              <TableCell colSpan={3} align="center" sx={{ py: 3 }}>
                Brak przedmiotów w bazie. Kliknij "Dodaj przedmiot", aby utworzyć pierwszy.
              </TableCell>
            </TableRow>
          ) : (
            subjects.map((subject) => (
              <TableRow key={subject.id}>
                <TableCell width="10%">{subject.id}</TableCell>
                <TableCell>{subject.name}</TableCell>
                <TableCell align="right" width="20%">
                  <AdminActionButtons 
                    onEdit={() => handleOpenModal(subject)} 
                    onDelete={() => handleDelete(subject.id, subject.name)} 
                  />
                </TableCell>
              </TableRow>
            ))
          )}
        </AdminTable>
      )}


      <Dialog 
        open={isModalOpen} 
        onClose={handleCloseModal}
        fullWidth
        maxWidth="sm"
      >
        <form onSubmit={handleSubmit}>
          <DialogTitle>
            {editingSubject ? 'Edytuj przedmiot' : 'Dodaj nowy przedmiot'}
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
              label="Nazwa przedmiotu"
              value={subjectName}
              onChange={(e) => setSubjectName(e.target.value)}
              disabled={isSubmitting}
              autoFocus 
            />
          </DialogContent>
          
          <DialogActions sx={{ px: 3, pb: 3 }}>
            
            <AdminButton 
              onClick={handleCloseModal} 
              disabled={isSubmitting}
              color="inherit"
            >
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