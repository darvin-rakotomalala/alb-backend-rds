package com.ce.controller;

import com.ce.constraint.validation.NoteValidator;
import com.ce.model.dto.NoteDTO;
import com.ce.service.application.NoteCUDSA;
import com.ce.service.application.NoteRSA;
import com.ce.utils.HelpPage;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.MediaType;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping(path = "notes")
public class NoteController {

    private final NoteCUDSA noteCUDSA;
    private final NoteRSA noteRSA;
    private final NoteValidator noteValidator;

    @InitBinder("noteDTO")
    protected void initNoteDTOBinder(WebDataBinder webDataBinder) {
        webDataBinder.setValidator(noteValidator);
    }

    @Operation(summary = "WS used to create note")
    @PostMapping
    public NoteDTO createNote(@RequestBody @Validated NoteDTO noteDTO) {
        return noteCUDSA.createNote(noteDTO);
    }

    @Operation(summary = "WS used to save all notes")
    @PostMapping("/save-all")
    public List<NoteDTO> saveAllNotes(@RequestBody List<NoteDTO> notes) {
        return noteCUDSA.saveAllNotes(notes);
    }

    @Operation(summary = "WS used to update note")
    @PutMapping
    public NoteDTO updateNote(@RequestBody @Validated NoteDTO noteDTO) {
        return noteCUDSA.updateNote(noteDTO);
    }

    @Operation(summary = "WS used to get all notes")
    @GetMapping
    public HelpPage<NoteDTO> getAllNotes(
            @RequestParam(name = "title", required = false) String title,
            @RequestParam(defaultValue = "0", required = false) int page,
            @RequestParam(defaultValue = "15", required = false) int size) {
        Pageable pageable = PageRequest.of(page, size);
        return noteRSA.getAllNotesByTitle(title, pageable);
    }

    @Operation(summary = "WS used to get note by id")
    @GetMapping("/{id}")
    public NoteDTO getNoteById(@PathVariable("id") Long id) {
        return noteRSA.getNoteById(id);
    }

    @Operation(summary = "WS used to delete note by id")
    @DeleteMapping(value = "/{id}", produces = MediaType.TEXT_PLAIN_VALUE + ";charset=UTF-8")
    public String deleteNoteById(@PathVariable("id") Long id) {
        noteCUDSA.deleteNoteById(id);
        return "Note with id " + id + " deleted successfully!";
    }

}
