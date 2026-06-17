import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { getComments, deleteComment } from '../api/adminComments';

export const useCommentsQuery = () => {
  return useQuery({
    queryKey: ['comments'],
    queryFn: getComments
  });
};

export const useDeleteComment = () => {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteComment,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['comments'] });
    }
  });
};