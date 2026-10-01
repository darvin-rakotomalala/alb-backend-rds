package com.ce.constraint.validation;

import com.ce.exception.ErrorsEnum;
import com.ce.model.dto.NoteDTO;
import org.apache.commons.lang3.StringUtils;
import org.jspecify.annotations.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.validation.Errors;
import org.springframework.validation.Validator;

@Component
public class NoteValidator implements Validator {

    @Override
    public boolean supports(@NonNull Class<?> clazz) {
        return NoteDTO.class.equals(clazz);
    }

    @Override
    public void validate(@NonNull Object target, @NonNull Errors errors) {
        NoteDTO noteDTO = (NoteDTO) target;
        if (StringUtils.isEmpty(noteDTO.getTitle())) {
            errors.rejectValue("title", "title.value.empty", ErrorsEnum.ERR_MCS_NOTE_TITLE_EMPTY.getErrorMessage());
        }
    }

}
