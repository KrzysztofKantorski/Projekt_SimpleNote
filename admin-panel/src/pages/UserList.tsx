import { useNavigate } from 'react-router-dom';
import { 
  Box, TableCell, TableRow,
  CircularProgress, Alert, Chip
} from '@mui/material';


import { AdminPageHeader } from '../components/AdminPageHeader';
import { AdminActionButtons } from '../components/AdminActionButtons';
import { AdminTable } from '../components/AdminTable';
import { useBanUser, useUsersQuery } from '../hooks/useUsers';
import { useState } from 'react';
import { CustomPagination } from '../components/Pagination';

export const UserList = () => {
  const [page, setPage] = useState<number>(1);
  const pageSize = 5;
  const navigate = useNavigate();
  const { data: users, isLoading, isError, error } = useUsersQuery(page, pageSize);
  const banMutation = useBanUser();

  // Handler ląduje w widoku
  const handleBan = (id: number, username: string, isActive: boolean) => {
    const actionText = isActive ? 'zbanować' : 'odbanować';
    if (window.confirm(`Czy na pewno chcesz ${actionText} użytkownika: ${username}?`)) {
      banMutation.mutate(id);
    }
  };

   const handlePageChange = (_event: React.ChangeEvent<unknown>, newPage: number) => {
    setPage(newPage);
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
        <>
          <AdminTable headers={['ID', 'Nazwa użytkownika', 'Status', 'Zarejestrowany', 'Akcje']}>
            {users.items.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5} align="center" sx={{ py: 3 }}>
                  Brak użytkowników w bazie danych
                </TableCell>
              </TableRow>
            ) : (
              users.items.map((user) => (
                <>
                
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

                </>
              ))
            )}
          </AdminTable>

          <CustomPagination 
            totalPages={users.totalPages}
            currentPage={users.currentPage}
            onPageChange={handlePageChange}
          />
        </>
      )}
    </Box>
  );
};