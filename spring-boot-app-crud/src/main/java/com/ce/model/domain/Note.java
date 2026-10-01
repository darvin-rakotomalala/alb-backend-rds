package com.ce.model.domain;

import com.ce.model.common.AuditModel;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "notes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Note extends AuditModel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String title;
    private String content;
}
