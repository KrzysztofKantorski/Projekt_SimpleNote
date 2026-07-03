import { api } from './axiosConfig';
import type { UserSummaryDto, UserDetailsAdminDto } from '../types/userTypes';
import type { PagedResult } from '../types/paginationTypes';


export const getAllUsers = async (pageNumber: number, pageSize: number): Promise<PagedResult<UserSummaryDto>> => {
  const response = await api.get<PagedResult<UserSummaryDto>>('/admin/users', 
    {
      params: { 
        pageNumber, 
        pageSize 
    }
  });
  return response.data;
};


export const getUserDetails = async (id: number): Promise<UserDetailsAdminDto> => {
  const response = await api.get<UserDetailsAdminDto>(`/admin/users/${id}`);
  return response.data;
};

export const banUser = async (id: number): Promise<void> => {
  await api.patch(`/admin/users/${id}/ban`);
};