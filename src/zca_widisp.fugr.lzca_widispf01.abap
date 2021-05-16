*&---------------------------------------------------------------------*
*&  Include           LZCA_WIDISPF01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  display_document
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_document USING p_row    TYPE i
                          p_column TYPE lvc_fname.
  DATA: ls_swotobjid TYPE swotobjid,
        lv_call_mode TYPE swf_calmod VALUE '02'.


  READ TABLE gt_attachments INTO DATA(ls_attach) INDEX p_row.
  IF sy-subrc EQ 0.

    ls_swotobjid-objtype = ls_attach-atypeid.
    ls_swotobjid-objkey = ls_attach-ainstid.

    CALL FUNCTION 'SWL_TRIGGER_DEFAULT_METHOD'
      EXPORTING
        object_por                 = ls_swotobjid
        call_mode                  = lv_call_mode
      EXCEPTIONS
        its_no_object              = 1
        error_while_calling_method = 2
        OTHERS                     = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDFORM.                    " display_document
