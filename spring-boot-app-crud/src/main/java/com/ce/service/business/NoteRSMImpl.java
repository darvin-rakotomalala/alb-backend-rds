package com.ce.service.business;

import com.ce.exception.ErrorsEnum;
import com.ce.exception.FunctionalException;
import com.ce.model.domain.Note;
import com.ce.repository.NoteRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import jakarta.transaction.Transactional;

import java.util.Optional;

@Transactional
@Slf4j
@RequiredArgsConstructor
@Service
public class NoteRSMImpl implements NoteRSM {

    private final NoteRepository noteRepository;

    @Override
    public Note getNoteById(Long id) {
        try {
            Optional<Note> optionalNote = noteRepository.findById(id);
            if (optionalNote.isEmpty()) {
                throw new FunctionalException(ErrorsEnum.ERR_MCS_NOTE_NOT_FOUND.getErrorMessage());
            }
            return optionalNote.get();
        } catch (Exception e) {
            log.error("Error getNoteById : {}", e.getMessage(), e);
            throw e;
        }
    }

    @Override
    public Page<Note> getAllNotesByTitle(String title, Pageable pageable) {
        try {
            if (StringUtils.isBlank(title)) {
                return noteRepository.findAll(pageable);
            } else {
                return noteRepository.findByTitleContainingIgnoreCase(title, pageable);
            }
        } catch (Exception e) {
            log.error("Error getAllNotesByTitle : {}", e.getMessage(), e);
            throw e;
        }
    }

}
