import { Box, Typography, Paper, Grid, CircularProgress, Alert } from '@mui/material';
import { useDashboardStatsQuery } from '../hooks/useStats';
import { AdminPageHeader } from '../components/AdminPageHeader';

import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js';
import { Doughnut, Line, Bar } from 'react-chartjs-2';

ChartJS.register(
  CategoryScale, LinearScale, PointElement, LineElement, 
  BarElement, ArcElement, Title, Tooltip, Legend
);


export const Dashboard = () => {
  const { data: stats, isLoading, isError, error } = useDashboardStatsQuery();

  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', height: '80vh', justifyContent: 'center', alignItems: 'center' }}>
        <CircularProgress />
      </Box>
    );
  }

  if (isError) {
    return (
      <Box sx={{ p: 3 }}>
        <Alert severity="error">
          Błąd ładowania statystyk: {(error as Error).message}
        </Alert>
      </Box>
    );
  }


  const usersChartData = {
    labels: ['Aktywni', 'Zbanowani'],
    datasets: [
      {
        data: [stats?.users.active || 0, stats?.users.banned || 0],
        backgroundColor: ['#6A89A7', '#384959'], 
        borderWidth: 1,
      },
    ],
  };

  const notesLineData = {
    labels: stats?.notesOverTime.map(item => item.date) || [],
    datasets: [
      {
        label: 'Ilość nowych notatek',
        data: stats?.notesOverTime.map(item => item.count) || [],
        borderColor: '#6A89A7', // Primary MUI
        backgroundColor: 'rgba(25, 118, 210, 0.2)',
        fill: true,
        tension: 0.3, 
      },
    ],
  };


  const subjectsBarData = {
    labels: stats?.subjectsDistribution.map(item => item.subjectName) || [],
    datasets: [
      {
        label: 'Ilość notatek',
        data: stats?.subjectsDistribution.map(item => item.count) || [],
        backgroundColor: '#6A89A7', 
      },
    ],
  };

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { position: 'bottom' as const }
    }
  };

  return (
    <Box>
      <AdminPageHeader title="Panel Główny - Statystyki" />
      
      <Grid container spacing={3} sx={{ mt: 1 }}>
        
        <Grid size={{ xs: 12, md: 4 }}>
          <Paper elevation={3} sx={{ p: 3, height: '350px', display: 'flex', flexDirection: 'column' }}>
            <Typography variant="h6" gutterBottom color="text.secondary" align="center">
              Status Użytkowników
            </Typography>
            <Box sx={{ flexGrow: 1, position: 'relative' }}>
              <Doughnut data={usersChartData} options={chartOptions} />
            </Box>
          </Paper>
        </Grid>

        <Grid size={{ xs: 12, md: 8 }}>
          <Paper elevation={3} sx={{ p: 3, height: '350px', display: 'flex', flexDirection: 'column' }}>
            <Typography variant="h6" gutterBottom color="text.secondary" align="center">
              Aktywność (Nowe notatki)
            </Typography>
            <Box sx={{ flexGrow: 1, position: 'relative' }}>
              <Line data={notesLineData} options={chartOptions} />
            </Box>
          </Paper>
        </Grid>
        <Grid size={{ xs: 12 }}>
          <Paper elevation={3} sx={{ p: 3, height: '400px', display: 'flex', flexDirection: 'column' }}>
            <Typography variant="h6" gutterBottom color="text.secondary" align="center">
              Rozkład Notatek wg Przedmiotów
            </Typography>
            <Box sx={{ flexGrow: 1, position: 'relative' }}>
              <Bar data={subjectsBarData} options={chartOptions} />
            </Box>
          </Paper>
        </Grid>

      </Grid>
    </Box>
  );
};