import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Box, Typography, Paper, Alert, CircularProgress } from '@mui/material';
import { loginAdmin } from '../api/auth';
import { getMe } from '../api/users';

import { AdminInput } from '../components/AdminInput';
import { AdminButton } from '../components/AdminButton';
import { useMutation } from '@tanstack/react-query';
import type { LoginDto } from '../types/authTypes';

export const Login = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [validationError, setValidationError] = useState('');
  const navigate = useNavigate();

  const loginMutation = useMutation({
    mutationFn: async (credentials: LoginDto) => {
      const response = await loginAdmin(credentials);
      localStorage.setItem('token', response.tokens.accessToken);

      // Get user info
      const userProfile = await getMe();

      if (userProfile.role?.toLowerCase() !== 'admin') {
        localStorage.removeItem('token');
        throw new Error('Odmowa dostępu. Wymagane uprawnienia administratora.');
      }

      return userProfile; 
    },
    onSuccess: () => {
      localStorage.setItem('isAuthenticated', 'true');
      navigate('/');
    },
    onError: () => {
      setPassword(''); 
    }
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault(); 
    setValidationError(''); 
    loginMutation.reset();  

    if (!username || !password) {
      setValidationError('Pola nie mogą być puste.');
      return;
    }
    
    loginMutation.mutate({ username, password });
  }

  return (
    <Box 
      sx={{ 
          height: '100vh', 
          display: 'flex', 
          alignItems: 'center', 
          justifyContent: 'center', 
          bgcolor: 'background.default' 
        }}
      >
      <Paper elevation={3} sx={{ p: 4, width: '100%', maxWidth: 400 }}>

       <Typography 
          variant="h3" 
          component="h5" 
          sx={{textAlign: "center", mb: 3}}
        >
          Admin Panel
        </Typography>

        {validationError && (
          <Alert severity="warning" sx={{ mb: 2 }}>{validationError}</Alert>
        )}

        {loginMutation.isError && (
        <Alert severity="error" sx={{ mb: 2 }}>
          {(loginMutation.error as Error).message || 'Niepoprawne dane logowania.'}
        </Alert>
        )}

        <form onSubmit={handleSubmit}>
          <AdminInput
            label="Username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            disabled={loginMutation.isPending}
          />
          
          <AdminInput
            label="Hasło"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            disabled={loginMutation.isPending}
          />
          
          <AdminButton 
            type="submit" 
            disabled={loginMutation.isPending}
            startIcon={loginMutation.isPending ? <CircularProgress size={20} color="inherit" /> : null}
            sx={{ mt: 2 }}
          >
          {loginMutation.isPending ? 'Logowanie...' : 'Zaloguj się'}
          </AdminButton>
        </form>
      </Paper>
    </Box>
  );
};