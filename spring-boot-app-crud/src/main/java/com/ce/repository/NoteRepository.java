package com.ce.repository;

import com.ce.model.domain.Note;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface NoteRepository extends JpaRepository<Note, Long> {
    @Query("SELECT n FROM Note n WHERE lower(n.title) like %:title%")
    Page<Note> findByTitleContainingIgnoreCase(String title, Pageable pageable);
}
