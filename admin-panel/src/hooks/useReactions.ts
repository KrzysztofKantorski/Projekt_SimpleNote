import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { 
  getReactions, 
  createReaction, 
  updateReaction, 
  deleteReaction 
} from '../api/adminReactions';
import type { CreateReactionTypeDto } from '../types/reactionTypes';


export const useReactionsQuery = (pageNumber: number, pageSize: number) => {
  return useQuery({
    queryKey: ['reactions', pageNumber, pageSize],
    queryFn: ()=> getReactions(pageNumber, pageSize),
  });
};


export const useDeleteReaction = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteReaction,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['reactions'] });
    }
  });
};


export const useCreateReaction = (onSuccessCallback?: () => void) => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: createReaction,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['reactions'] });
      if (onSuccessCallback) onSuccessCallback(); 
    }
  });
};


export const useUpdateReaction = (onSuccessCallback?: () => void) => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: number, data: CreateReactionTypeDto }) => updateReaction(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['reactions'] });
      if (onSuccessCallback) onSuccessCallback();
    }
  });
};