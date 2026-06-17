import { api } from './axiosConfig';
import type { ReactionTypeDto, CreateReactionTypeDto } from '../types/reactionTypes';


export const getReactions = async (): Promise<ReactionTypeDto[]> => {
  const response = await api.get<ReactionTypeDto[]>('/admin/reactions');
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