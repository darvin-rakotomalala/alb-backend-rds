package com.ce.mapper;

import com.ce.common.mapper.DtoMapper;
import com.ce.model.domain.Note;
import com.ce.model.dto.NoteDTO;
import org.mapstruct.Mapper;

@Mapper
public interface NoteMapper extends DtoMapper<NoteDTO, Note> {

}
