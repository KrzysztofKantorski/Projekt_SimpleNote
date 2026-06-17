import { api } from './axiosConfig';
import type { CommentDto } from '../types/commentTypes';


export const getComments = async (): Promise<CommentDto[]> => {
  const response = await api.get<CommentDto[]>('/admin/comments');
  return response.data;
};

export const deleteComment = async (id: number): Promise<void> => {
  await api.delete(`/admin/comments/${id}`);
};