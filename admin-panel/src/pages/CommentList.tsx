import { 
  Box, TableCell, TableRow, CircularProgress, Alert, IconButton 
} from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import { useCommentsQuery, useDeleteComment } from '../hooks/useComments';
import { AdminPageHeader } from '../components/AdminPageHeader';
import { AdminTable } from '../components/AdminTable';
import type { CommentDto } from '../types/commentTypes';

export const CommentList = () => {
  const { data: comments, isLoading, isError, error } = useCommentsQuery();
  const deleteMutation = useDeleteComment();

  const handleDelete = (id: number) => {
    if (window.confirm('Czy na pewno chcesz ukryć ten komentarz wraz ze wszystkimi odpowiedziami?')) {
      deleteMutation.mutate(id);
    }
  };

  const renderComment = (comment: CommentDto, depth: number = 0) => {
    const rows = [];

    rows.push(
      <TableRow key={comment.id} sx={{ '& > td': { pl: depth * 4 + 2 } }}>
        <TableCell>{comment.authorName}</TableCell>
        <TableCell>{comment.content}</TableCell>
        <TableCell>
          {new Date(comment.createdAt).toLocaleDateString()}
        </TableCell>
        <TableCell align="right">
          <IconButton color="error" onClick={() => handleDelete(comment.id)}>
            <DeleteIcon />
          </IconButton>
        </TableCell>
      </TableRow>
    );

    if (comment.replies && comment.replies.length > 0) {
      comment.replies.forEach(reply => {
        rows.push(...renderComment(reply, depth + 1));
      });
    }

    return rows;
  };

  return (
    <Box>
      <AdminPageHeader title="Zarządzanie komentarzami" />

      {isLoading && <CircularProgress sx={{ display: 'block', margin: '40px auto' }} />}
      {isError && <Alert severity="error">{(error as Error).message}</Alert>}

      {!isLoading && !isError && comments && (
        <AdminTable headers={['Autor', 'Treść', 'Data', 'Akcje']}>
          {comments.length === 0 ? (
            <TableRow>
              <TableCell colSpan={4} align="center">Brak komentarzy.</TableCell>
            </TableRow>
          ) : (
            comments.map(comment => renderComment(comment))
          )}
        </AdminTable>
      )}
    </Box>
  );
};