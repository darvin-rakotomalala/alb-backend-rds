package com.ce.exception;

import lombok.Getter;

@Getter
public enum ErrorsEnum {

    /**
     * ERR_MCS_POC
     */

    ERR_MCS_NOTE_TITLE_EMPTY("Error occurred - Note title shouldn't be NULL or EMPTY"),
    ERR_MCS_NOTE_OBJECT_EMPTY("Error occurred - object Note shouldn't be NULL or EMPTY"),
    ERR_MCS_NOTE_NOT_FOUND("Error occurred - no Note found with this id");

    private final String errorMessage;

    private ErrorsEnum(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    @Override
    public String toString() {
        return " errorMessage : " + errorMessage;
    }

}
