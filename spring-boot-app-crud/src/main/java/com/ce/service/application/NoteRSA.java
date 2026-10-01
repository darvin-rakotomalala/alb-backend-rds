package com.ce.service.application;

import com.ce.model.dto.NoteDTO;
import com.ce.utils.HelpPage;
import org.springframework.data.domain.Pageable;

public interface NoteRSA {
    NoteDTO getNoteById(Long id);

    HelpPage<NoteDTO> getAllNotesByTitle(String title, Pageable pageable);
}
