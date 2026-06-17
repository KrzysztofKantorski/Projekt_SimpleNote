import React from 'react';
import ReactDOM from 'react-dom/client';
import { App } from './App';
import CssBaseline from '@mui/material/CssBaseline';
import { ThemeProvider } from '@emotion/react';
import { theme } from './theme';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
// import './index.css' // Możesz na razie usunąć lub zakomentować domyślne style Vite

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false, // Opcjonalnie: żeby nie odświeżało danych za każdym razem jak klikniesz w okno
      retry: 1, // Ile razy ponowić próbę jeśli serwer zwróci błąd
    },
  },
});


ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>
        {/* CssBaseline resetuje style przeglądarki i ustawia tło na to z naszego motywu */}
        <CssBaseline />
        <App />
      </ThemeProvider>
    </QueryClientProvider>
    
  </React.StrictMode>,
);
