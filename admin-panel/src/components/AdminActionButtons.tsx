import { IconButton } from '@mui/material';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';

interface AdminActionButtonsProps {
  onEdit: () => void;
  onDelete: () => void;
}

export const AdminActionButtons = ({ onEdit, onDelete }: AdminActionButtonsProps) => {
  return (
    <>
      <IconButton color="secondary" onClick={onEdit} title="Edit">
        <EditIcon />
      </IconButton>
      <IconButton color="error" onClick={onDelete} title="Delete">
        <DeleteIcon />
      </IconButton>
    </>
  );
};