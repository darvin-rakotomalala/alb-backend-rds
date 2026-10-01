package com.ce.service.application;

import com.ce.model.dto.NoteDTO;

import java.util.List;

public interface NoteCUDSA {
    NoteDTO createNote(NoteDTO noteDTO);

    List<NoteDTO> saveAllNotes(List<NoteDTO> notes);

    NoteDTO updateNote(NoteDTO noteDTO);

    void deleteNoteById(Long id);
}
