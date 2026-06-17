import { useParams, useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { 
  Box, CircularProgress, Alert, Paper, Typography, Grid, Chip, Divider
} from '@mui/material';

// Importy naszego API i komponentów
import { getUserDetails } from '../api/adminUsers';
import { AdminPageHeader } from '../components/AdminPageHeader';

export const UserDetails = () => {
  //Get user id
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();

  //Get user details
  const { data: user, isLoading, isError, error } = useQuery({
    queryKey: ['user', id],
    queryFn: () => getUserDetails(Number(id)),
    enabled: !!id, 
  });

  console.log(`user: ${user}`)
  return (
    <Box>
      <AdminPageHeader 
        title={user ? `Profil: ${user.username}` : "Szczegóły użytkownika"} 
        actionText="Wróć do listy" 
        onAction={() => navigate('/users')} 
      />

      {isLoading && 
        <CircularProgress
          sx={{ display: 'block', margin: '40px auto' }} 
        />
      }
      
      {isError && 
        <Alert severity="error" sx={{ mb: 3 }}>
          Wystąpił błąd podczas pobierania danych: {(error as Error).message}
        </Alert>
      }

      {!isLoading && !isError && user && (
        <Paper elevation={3} sx={{ p: 4, mt: 2 }}>
          <Typography variant="h6" gutterBottom color="primary">
            Podstawowe informacje
          </Typography>
          
          <Grid container spacing={3} sx={{ mb: 4 }}>
            <Grid size={{ xs: 12, sm: 6 }}>
              <Typography variant="subtitle2" color="text.secondary">ID w bazie</Typography>
              <Typography variant="body1">{user.id}</Typography>
            </Grid>
            <Grid size={{ xs: 12, sm: 6 }}>
              <Typography variant="subtitle2" color="text.secondary">Nazwa użytkownika</Typography>
              <Typography variant="body1">{user.username}</Typography>
            </Grid>
            <Grid size={{ xs: 12, sm: 6 }}>
              <Typography variant="subtitle2" color="text.secondary">Status konta</Typography>
              <Chip 
                label={user.isActive ? 'Aktywny' : 'Zbanowany'} 
                color={user.isActive ? 'success' : 'error'} 
                size="small" 
                sx={{ mt: 0.5 }}
              />
            </Grid>
            <Grid size={{ xs: 12, sm: 6 }}>
              <Typography variant="subtitle2" color="text.secondary">Data rejestracji</Typography>
              <Typography variant="body1">
                {new Date(user.createdAt).toLocaleDateString('pl-PL', {
                  year: 'numeric',
                  month: 'long',
                  day: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit'
                })}
              </Typography>
            </Grid>
          </Grid>

          <Divider sx={{ mb: 4 }} />

          <Typography variant="h6" gutterBottom color="primary">
            Aktywność w aplikacji
          </Typography>

          <Grid container spacing={3}>
            <Grid size={{ xs: 10, sm: 4 }}>
              <Box sx={{ p: 2, bgcolor: 'background.default', borderRadius: 1, textAlign: 'center' }}>
                <Typography variant="h4" color="secondary">{user.totalNotes}</Typography>
                <Typography variant="body2" color="text.secondary">Utworzone notatki</Typography>
              </Box>
            </Grid>
            <Grid size={{ xs: 12, sm: 4 }}>
              <Box sx={{ p: 2, bgcolor: 'background.default', borderRadius: 1, textAlign: 'center' }}>
                <Typography variant="h4" color="secondary">{user.totalComments}</Typography>
                <Typography variant="body2" color="text.secondary">Napisane komentarze</Typography>
              </Box>
            </Grid>
            <Grid size={{ xs: 12, sm: 4 }}>
              <Box sx={{ p: 2, bgcolor: 'background.default', borderRadius: 1, textAlign: 'center' }}>
                <Typography variant="h4" color="secondary">{user.totalReactions}</Typography>
                <Typography variant="body2" color="text.secondary">Zostawione reakcje</Typography>
              </Box>
            </Grid>
          </Grid>

          <Divider sx={{ mb: 4 }} />

         

         
        </Paper>
      )}
    </Box>
  );
};