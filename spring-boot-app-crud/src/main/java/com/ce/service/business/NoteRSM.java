package com.ce.service.business;

import com.ce.model.domain.Note;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface NoteRSM {
    public Note getNoteById(Long id);

    public Page<Note> getAllNotesByTitle(String title, Pageable pageable);
}
