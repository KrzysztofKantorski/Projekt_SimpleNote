import { api } from './axiosConfig';
import type { UserSummaryDto, UserDetailsAdminDto } from '../types/userTypes';


export const getAllUsers = async (): Promise<UserSummaryDto[]> => {
  const response = await api.get<UserSummaryDto[]>('/admin/users');
  return response.data;
};


export const getUserDetails = async (id: number): Promise<UserDetailsAdminDto> => {
  const response = await api.get<UserDetailsAdminDto>(`/admin/users/${id}`);
  return response.data;
};

export const banUser = async (id: number): Promise<void> => {
  await api.patch(`/admin/users/${id}/ban`);
};