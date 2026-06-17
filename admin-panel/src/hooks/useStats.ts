import { useQuery } from '@tanstack/react-query';
import { getDashboardStats } from '../api/adminStats';

export const useDashboardStatsQuery = () => {
  return useQuery({
    queryKey: ['dashboard-stats'],
    queryFn: getDashboardStats
  });
};