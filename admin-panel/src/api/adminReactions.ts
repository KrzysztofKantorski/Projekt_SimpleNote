import { api } from './axiosConfig';
import type { ReactionTypeDto, CreateReactionTypeDto } from '../types/reactionTypes';
import type { PagedResult } from '../types/paginationTypes';


export const getReactions = async (pageNumber: number, pageSize: number): Promise<PagedResult<ReactionTypeDto>> => {
  const response = await api.get<PagedResult<ReactionTypeDto>>('/admin/reactions', 
    {
      params: {
          PageNumber: pageNumber,
          PageSize: pageSize
        }
    }
  );
  return response.data;
};


export const createReaction = async (data: CreateReactionTypeDto): Promise<ReactionTypeDto> => {
  const response = await api.post<ReactionTypeDto>('/admin/reactions', data);
  return response.data;
};


export const updateReaction = async (id: number, data: CreateReactionTypeDto): Promise<ReactionTypeDto> => {
  const response = await api.put<ReactionTypeDto>(`/admin/reactions/${id}`, data);
  return response.data;
};


export const deleteReaction = async (id: number): Promise<void> => {
  await api.delete(`/admin/reactions/${id}`);
};