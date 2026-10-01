package com.ce.service.business;

import com.ce.model.domain.Note;

import java.util.List;

public interface NoteCUDSM {
    Note createOrUpdateNote(Note note);

    List<Note> saveAllNotes(List<Note> notes);

    void deleteNoteById(Long id);
}
