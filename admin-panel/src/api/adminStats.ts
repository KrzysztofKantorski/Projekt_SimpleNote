import { api } from './axiosConfig';
import type { DashboardStatsDto } from '../types/statsTypes';


export const getDashboardStats = async (): Promise<DashboardStatsDto> => {
  const response = await api.get<DashboardStatsDto>('/admin/stats');
  return response.data;
};