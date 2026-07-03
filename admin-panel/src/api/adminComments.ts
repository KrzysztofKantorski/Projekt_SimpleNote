import { api } from './axiosConfig';
import type { CommentDto } from '../types/commentTypes';
import type { PagedResult } from '../types/paginationTypes';


export const getComments = async (pageNumber: number, pageSize: number): Promise<PagedResult<CommentDto>> => {
  const response = await api.get<PagedResult<CommentDto>>('/admin/comments', 
    {
      params: {
        PageNumber: pageNumber,
        PageSize: pageSize
      }
    }
  )
  return response.data;
};

export const deleteComment = async (id: number): Promise<void> => {
  await api.delete(`/admin/comments/${id}`);
};