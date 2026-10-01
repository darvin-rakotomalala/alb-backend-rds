package com.ce.service.business;

import com.ce.model.domain.Note;
import com.ce.repository.NoteRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jspecify.annotations.NonNull;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final NoteRepository noteRepository;

    @Override
    public void run(String @NonNull ... args) {
        if (noteRepository.count() == 0) {
            noteRepository.saveAll(List.of(
                    new Note(null, "Welcome Note", "This is your first note!"),
                    new Note(null, "Shopping List", "Milk, Eggs, Bread, Coffee"),
                    new Note(null, "Meeting Notes", "Discuss Q3 roadmap with the team"),
                    new Note(null, "Ideas", "Build a note-taking app with tags and search")
            ));
            log.info("##### Sample notes inserted into database.");
        }
    }
}
