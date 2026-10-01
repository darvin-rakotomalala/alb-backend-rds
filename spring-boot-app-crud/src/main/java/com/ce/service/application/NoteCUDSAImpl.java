package com.ce.service.application;

import com.ce.exception.ErrorsEnum;
import com.ce.exception.FunctionalException;
import com.ce.model.domain.Note;
import com.ce.model.dto.NoteDTO;
import com.ce.mapper.NoteMapper;
import com.ce.service.business.NoteCUDSM;
import com.ce.service.business.NoteRSM;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Service
public class NoteCUDSAImpl implements NoteCUDSA {

    private final NoteCUDSM noteCUDSM;
    private final NoteRSM noteRSM;
    private final NoteMapper noteMapper;

    @Override
    public NoteDTO createNote(NoteDTO noteDTO) {
        if (noteDTO == null) {
            throw new FunctionalException(ErrorsEnum.ERR_MCS_NOTE_OBJECT_EMPTY.getErrorMessage());
        }
        Note savedNote = noteCUDSM.createOrUpdateNote(noteMapper.toDO(noteDTO));
        return noteMapper.toDTO(savedNote);
    }

    @Override
    public List<NoteDTO> saveAllNotes(List<NoteDTO> notes) {
        return noteMapper.toDTO(noteCUDSM.saveAllNotes(noteMapper.toDO(notes)));
    }

    @Override
    public NoteDTO updateNote(NoteDTO noteDTO) {
        if (noteDTO == null || noteDTO.getId() == null) {
            throw new FunctionalException(ErrorsEnum.ERR_MCS_NOTE_OBJECT_EMPTY.getErrorMessage());
        }
        Note noteFound = noteRSM.getNoteById(noteDTO.getId());
        noteFound.setTitle(noteDTO.getTitle());
        noteFound.setContent(noteDTO.getContent());
        return noteMapper.toDTO(noteCUDSM.createOrUpdateNote(noteFound));
    }

    @Override
    public void deleteNoteById(Long id) {
        noteCUDSM.deleteNoteById(id);
    }
}
