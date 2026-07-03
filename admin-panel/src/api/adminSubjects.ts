import { api } from './axiosConfig';
import type { SubjectDto, SubjectRequestDto } from '../types/subjectTypes';
import type { PagedResult } from '../types/paginationTypes';

export const getSubjects = async (pageNumber: number, pageSize: number): Promise<PagedResult<SubjectDto>> => {
  const response = await api.get<PagedResult<SubjectDto>>('/admin/subjects', {
    params: { 
      pageNumber, 
      pageSize 
    }
  });
  return response.data;
};

export const createSubject = async (data: SubjectRequestDto): Promise<SubjectDto> => {
  const response = await api.post<SubjectDto>('/admin/subjects', data);
  return response.data;
};

export const updateSubject = async (id: number, data: SubjectRequestDto): Promise<SubjectDto> => {
  const response = await api.put<SubjectDto>(`/admin/subjects/${id}`, data);
  return response.data;
};

export const deleteSubject = async (id: number): Promise<void> => {
  await api.delete(`/admin/subjects/${id}`);
};