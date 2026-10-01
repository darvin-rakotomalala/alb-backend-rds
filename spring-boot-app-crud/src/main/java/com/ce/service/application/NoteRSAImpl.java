package com.ce.service.application;

import com.ce.model.dto.NoteDTO;
import com.ce.mapper.NoteMapper;
import com.ce.service.business.NoteRSM;
import com.ce.utils.HelpPage;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class NoteRSAImpl implements NoteRSA {

    private final NoteRSM noteRSM;
    private final NoteMapper noteMapper;

    @Override
    public NoteDTO getNoteById(Long id) {
        return noteMapper.toDTO(noteRSM.getNoteById(id));
    }

    @Override
    public HelpPage<NoteDTO> getAllNotesByTitle(String title, Pageable pageable) {
        return noteMapper.toDTO(noteRSM.getAllNotesByTitle(title, pageable), pageable);
    }

}
