import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { getComments, deleteComment } from '../api/adminComments';

export const useCommentsQuery = (pageNumber: number, pageSize: number) => {
  return useQuery({
    queryKey: ['comments', pageNumber, pageSize],
    queryFn: () => getComments(pageNumber, pageSize),
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