import { useNavigate } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { 
  Box, TableCell, TableRow,
  CircularProgress, Alert, Chip
} from '@mui/material';

// Importy z naszych nowych plików
import { getAllUsers, banUser } from '../api/adminUsers';

// Twoje gotowe komponenty UI
import { AdminPageHeader } from '../components/AdminPageHeader';
import { AdminActionButtons } from '../components/AdminActionButtons';
import { AdminTable } from '../components/AdminTable';

export const UserList = () => {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  // Pobieranie listy użytkowników
  const { data: users, isLoading, isError, error } = useQuery({
    queryKey: ['users'],
    queryFn: getAllUsers
  });

  // Mutacja do banowania (zwraca 204 No Content, więc tylko odświeżamy tabelę)
  const banMutation = useMutation({
    mutationFn: banUser,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    }
  });

  // Handler do banowania z dynamicznym tekstem
  const handleBan = (id: number, username: string, isActive: boolean) => {
    const actionText = isActive ? 'zbanować' : 'odbanować';
    if (window.confirm(`Czy na pewno chcesz ${actionText} użytkownika: ${username}?`)) {
      banMutation.mutate(id);
    }
  };

  return (
    <Box>
      <AdminPageHeader 
        title="Zarządzanie użytkownikami" 
      />

      {isLoading && 
        <CircularProgress
          sx={{
            display: 'block',
            margin: '40px auto' 
          }} 
        />
      }
      
      {isError && 
        <Alert severity="error">
          Wystąpił błąd podczas pobierania danych: {(error as Error).message}
        </Alert>
      }

      {!isLoading && !isError && users && (
        <AdminTable headers={['ID', 'Nazwa użytkownika', 'Status', 'Zarejestrowany', 'Akcje']}>
          {users.length === 0 ? (
            <TableRow>
              <TableCell colSpan={5} align="center" sx={{ py: 3 }}>
                Brak użytkowników w bazie danych
              </TableCell>
            </TableRow>
          ) : (
            users.map((user) => (
              <TableRow key={user.id}>
                <TableCell>{user.id}</TableCell>
                <TableCell>{user.username}</TableCell>
                <TableCell>
                  <Chip 
                    label={user.isActive ? 'Aktywny' : 'Zbanowany'} 
                    color={user.isActive ? 'success' : 'error'} 
                    size="small"
                  />
                </TableCell>
                <TableCell>
                  {/* Formatowanie daty na czytelny string */}
                  {new Date(user.createdAt).toLocaleDateString('pl-PL', {
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                  })}
                </TableCell>
                <TableCell align="right">
                  <AdminActionButtons 
                    onEdit={() => navigate(`/users/${user.id}`)} 
                    onDelete={() => handleBan(user.id, user.username, user.isActive)} 
                  />
                </TableCell>
              </TableRow>
            ))
          )}
        </AdminTable>
      )}
    </Box>
  );
};