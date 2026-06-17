import { Link, Outlet, useNavigate } from 'react-router-dom';
import { Box, Typography } from '@mui/material';
import { AdminButton } from '../components/AdminButton';
import { useMutation } from '@tanstack/react-query';
import { logoutAdmin } from '../api/auth';

export const AdminLayout = () => {
  const navigate = useNavigate()
    const createMutation = useMutation({
        mutationFn: logoutAdmin,
        onSettled: () => {
        //Set flag to false
        localStorage.removeItem('isAuthenticated');
        navigate('/login'); 
      }
    });
    const handleSubmit = () => {
        createMutation.mutate();
    }
  return (
    <Box sx={{ display: 'flex', minHeight: '100vh' }}>

      <Box 
        component="aside" 
        sx={{ 
          width: '250px', 
          position: 'relative',
          bgcolor: 'text.primary', 
          color: 'background.paper', 
          padding: '20px' 
        }}
      >
        <Typography variant="h5" sx={{ mb: 4, fontWeight: 'bold' }}>
          Admin Panel
        </Typography>

        <Box 
          component="nav" 
          sx={{ 
            display: 'flex', 
            
            flexDirection: 'column', 
            gap: '15px',
            '& a': {
              color: 'background.paper', 
              textDecoration: 'none',
              fontSize: '1.1rem',
              transition: '0.2s',
              '&:hover': {
                color: 'secondary.main', 
              }
            }
          }}
        >
          <Link to="/">Panel</Link>
          <Link to="/users">Użytkownicy</Link>
          <Link to="/subjects">Przedmioty</Link>
          <Link to="/reactions">Reakcje</Link>
          <Link to="/comments">Komentarze</Link>
          <AdminButton
            sx={{
              position: 'absolute',
              bottom: '20px',
              left: '20px',
              width: 'calc(100% - 40px)',
            }}
            onClick={handleSubmit}
          >Wyloguj</AdminButton>
        </Box>
      </Box>
      <Box 
        component="main" 
        sx={{ 
          flex: 1, 
          padding: '30px', 
          bgcolor: 'background.default'
        }}
      >
         
        <Outlet /> 
      </Box>
      
    </Box>
  );
};