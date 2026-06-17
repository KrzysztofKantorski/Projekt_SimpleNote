import { api } from './axiosConfig';
import type { SubjectDto, SubjectRequestDto } from '../types/subjectTypes';

export const getSubjects = async (): Promise<SubjectDto[]> => {
  const response = await api.get<SubjectDto[]>('/admin/subjects');
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