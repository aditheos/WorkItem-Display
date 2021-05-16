*&---------------------------------------------------------------------*
*&  Include           LZCA_WIDISPO01
*&---------------------------------------------------------------------*
*&SPWIZARD: OUTPUT MODULE FOR TS 'GS_WF_INFO'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: SETS ACTIVE TAB
MODULE gs_wf_info_active_tab_set OUTPUT.
  gs_wf_info-activetab = g_gs_wf_info-pressed_tab.
  CASE g_gs_wf_info-pressed_tab.
    WHEN c_gs_wf_info-tab1.
      g_gs_wf_info-subscreen = '0011'.
    WHEN c_gs_wf_info-tab2.
      g_gs_wf_info-subscreen = '0012'.
    WHEN c_gs_wf_info-tab3.
      g_gs_wf_info-subscreen = '0013'.
    WHEN c_gs_wf_info-tab4.
      g_gs_wf_info-subscreen = '0014'.
    WHEN c_gs_wf_info-tab5.
      g_gs_wf_info-subscreen = '0015'.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0010  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0010 OUTPUT.
  DATA: lv_title TYPE string.
  SET PF-STATUS 'STATUS01'.

  IF NOT gv_title IS INITIAL.
    SET TITLEBAR 'TITLE02' WITH gv_title.
  ELSE.
    SET TITLEBAR 'TITLE01'.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0110  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0011 OUTPUT.
  DATA: lv_info_url TYPE char30.

  IF NOT go_info_cont IS BOUND.
    CREATE OBJECT go_info_cont
      EXPORTING
        container_name              = 'INFO'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      CREATE OBJECT go_info_html
        EXPORTING
          parent             = go_info_cont
        EXCEPTIONS
          cntl_error         = 1
          cntl_install_error = 2
          dp_install_error   = 3
          dp_error           = 4
          OTHERS             = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        CALL METHOD go_info_html->load_data
          IMPORTING
            assigned_url = lv_info_url
          CHANGING
            data_table   = gt_html_page
          EXCEPTIONS
            OTHERS       = 0.

        CALL METHOD go_info_html->show_url
          EXPORTING
            url                    = lv_info_url      " URL
          EXCEPTIONS
            cntl_error             = 1                " Error in CFW Call
            cnht_error_not_allowed = 2                " Navigation outside R/3 is not allowed
            cnht_error_parameter   = 3                " Incorrect parameters
            dp_error_general       = 4                " Error in DP FM call
            OTHERS                 = 5.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0012  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0012 OUTPUT.
  IF NOT go_agents_cont IS BOUND.
    CREATE OBJECT go_agents_cont
      EXPORTING
        container_name              = 'AGENTS'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      TRY.
          cl_salv_table=>factory(
            EXPORTING
              list_display   = if_salv_c_bool_sap=>false " ALV Displayed in List Mode
              r_container    = go_agents_cont            " Abstract Container for GUI Controls
            IMPORTING
              r_salv_table   = DATA(lo_agents_tab)       " Basis Class Simple ALV Tables
            CHANGING
              t_table        = gt_agents
          ).

          DATA(lo_columns) = lo_agents_tab->get_columns( ).

          " Agent ID
          TRY.
              DATA(lo_column) = lo_columns->get_column( columnname = 'USERID'  ).
              IF gv_show_userid IS INITIAL.
                lo_column->set_visible( abap_false ).
              ELSE.
                lo_column->set_short_text( 'Agent ID'(001) ).
                lo_column->set_medium_text( 'Agent ID'(001) ).
                lo_column->set_long_text( 'Agent ID'(001) ).
              ENDIF.
            CATCH cx_salv_not_found.
          ENDTRY.

          " Agent Name
          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'FULLNAME'  ).
              lo_column->set_output_length( value =  20 ).
              lo_column->set_short_text( 'Agent Name'(002) ).
              lo_column->set_medium_text( 'Agent Name'(002) ).
              lo_column->set_long_text( 'Agent Name'(002) ).
            CATCH cx_salv_not_found.
          ENDTRY.

          lo_agents_tab->display( ).
        CATCH cx_salv_msg.
      ENDTRY.
    ENDIF.
  ENDIF.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  STATUS_0013  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0013 OUTPUT.

  DATA lo_textview TYPE REF TO cl_salv_wd_uie_text_view.
  DATA lo_scolumns TYPE REF TO cl_salv_columns_table.
  DATA lo_scolumn  TYPE REF TO cl_salv_column_table.

  IF NOT go_comments_cont IS BOUND.
    CREATE OBJECT go_comments_cont
      EXPORTING
        container_name              = 'NOTES'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.

      CREATE OBJECT go_comment_text
        EXPORTING
          wordwrap_to_linebreak_mode = cl_gui_textedit=>true
          parent                     = go_comments_cont
        EXCEPTIONS
          error_cntl_create          = 1
          error_cntl_init            = 2
          error_cntl_link            = 3
          error_dp_create            = 4
          gui_type_not_supported     = 5
          OTHERS                     = 6.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        go_comment_text->set_statusbar_mode( ).
        go_comment_text->set_toolbar_mode( ).
        go_comment_text->set_readonly_mode(
          EXPORTING
            readonly_mode          = 1
        ).

        " Set Comment
        go_comment_text->set_textstream(
          EXPORTING
            text            = gs_comment       " text as stream with carrige retruns and linefeeds
        ).

        go_comment_text->set_first_visible_line(
        ).
      ENDIF.
    ENDIF.
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0014  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0014 OUTPUT.
  DATA: lo_tcolumns TYPE REF TO cl_salv_columns_table,
        lo_tcolumn  TYPE REF TO cl_salv_column_table,
        lo_events   TYPE REF TO cl_salv_events_table,
        ls_color    TYPE lvc_s_colo.
  INCLUDE <color>.
  IF NOT go_attach_cont IS BOUND.
    CREATE OBJECT go_attach_cont
      EXPORTING
        container_name              = 'ATTACHMENTS'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      TRY.
          cl_salv_table=>factory(
            EXPORTING
              list_display   = if_salv_c_bool_sap=>false " ALV Displayed in List Mode
              r_container    = go_attach_cont            " Abstract Container for GUI Controls
            IMPORTING
              r_salv_table   = DATA(lo_attach_tab)      " Basis Class Simple ALV Tables
            CHANGING
              t_table        = gt_attachments
          ).

          " Events
          lo_events = lo_attach_tab->get_event( ).

          CREATE OBJECT go_attach_events.
          SET HANDLER go_attach_events->on_double_click FOR lo_events.
          SET HANDLER go_attach_events->on_single_click FOR lo_events.

          CLEAR lo_columns.
          lo_columns = lo_attach_tab->get_columns( ).

          CLEAR lo_tcolumns.
          lo_tcolumns ?= lo_attach_tab->get_columns( ).

          lo_columns->set_optimize(
              value = if_salv_c_bool_sap=>false
          ).

          " File Name
          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'FILENAME'  ).
              lo_column->set_output_length( value = 40 ).
            CATCH cx_salv_not_found.
          ENDTRY.

          " Created By
          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'CREATED_BYNAME'  ).
              lo_column->set_output_length( value = 20 ).
              lo_column->set_short_text( 'By'(004) ).
              lo_column->set_medium_text( 'By'(004) ).
              lo_column->set_long_text( 'By'(004) ).

            CATCH cx_salv_not_found.
          ENDTRY.

          " Created On
          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'CREATED_DATE'  ).
              lo_column->set_output_length( value = 10 ).
              lo_column->set_short_text( 'Created On'(005) ).
              lo_column->set_medium_text( 'Created On'(005) ).
              lo_column->set_long_text( 'Created On'(005) ).
            CATCH cx_salv_not_found.
          ENDTRY.

          " Created On
          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'CREATED_TIME'  ).
              lo_column->set_output_length( value = 10 ).
              lo_column->set_short_text( 'Created At'(006) ).
              lo_column->set_medium_text( 'Created At'(006) ).
              lo_column->set_long_text( 'Created At'(006) ).
            CATCH cx_salv_not_found.
          ENDTRY.

          " ICON
          TRY.
              CLEAR lo_tcolumn.
              lo_tcolumn ?= lo_columns->get_column( columnname = 'ICON'  ).
              lo_tcolumn->set_icon(
                  value = if_salv_c_bool_sap=>true
              ).
              CLEAR ls_color.
              ls_color-col = col_group.
              ls_color-int = 0.
              ls_color-inv = 0.
              lo_tcolumn->set_color( value = ls_color ).
              lo_tcolumn->set_short_text( 'Display'(009) ).
              lo_tcolumn->set_medium_text( 'Display'(009) ).
              lo_tcolumn->set_long_text( 'Display'(009) ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'INSTANCE_ID'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'ID'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'MIME_TYPE'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'CREATED_AT'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'CREATED_BY'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'FILESIZE'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'ATTACHMENT_SUPPORTS'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'AINSTID'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'ATYPEID'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'ACATID'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          lo_attach_tab->display( ).
        CATCH cx_salv_msg.
      ENDTRY.
    ENDIF.
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0015  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0015 OUTPUT.
  IF NOT go_log_cont IS BOUND.
    CREATE OBJECT go_log_cont
      EXPORTING
        container_name              = 'LOGS'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      TRY.
          cl_salv_table=>factory(
            EXPORTING
              list_display   = if_salv_c_bool_sap=>false " ALV Displayed in List Mode
              r_container    = go_log_cont               " Abstract Container for GUI Controls
            IMPORTING
              r_salv_table   =  DATA(lo_log_tab)         " Basis Class Simple ALV Tables
            CHANGING
              t_table        = gt_logs
          ).

          CLEAR lo_columns.
          lo_columns = lo_log_tab->get_columns( ).
          lo_columns->set_optimize(
              value = if_salv_c_bool_sap=>false
          ).

          " Comments
          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'COMMENTS'  ).
              lo_column->set_output_length( value = 40 ).
              lo_column->set_short_text( 'Action Txt'(007) ).
              lo_column->set_medium_text( 'Action Text'(008) ).
              lo_column->set_long_text( 'Action Text'(008) ).
            CATCH cx_salv_not_found.
          ENDTRY.

          " Created By
          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'CREATED_BYNAME'  ).
              lo_column->set_output_length( value = 20 ).
              lo_column->set_short_text( 'By'(004) ).
              lo_column->set_medium_text( 'By'(004) ).
              lo_column->set_long_text( 'By'(004) ).

            CATCH cx_salv_not_found.
          ENDTRY.

          " Created On
          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'CREATED_DATE'  ).
              lo_column->set_output_length( value = 10 ).
              lo_column->set_short_text( 'Created On'(005) ).
              lo_column->set_medium_text( 'Created On'(005) ).
              lo_column->set_long_text( 'Created On'(005) ).
            CATCH cx_salv_not_found.
          ENDTRY.

          " Created On
          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'CREATED_TIME'  ).
              lo_column->set_output_length( value = 10 ).
              lo_column->set_short_text( 'Created At'(006) ).
              lo_column->set_medium_text( 'Created At'(006) ).
              lo_column->set_long_text( 'Created At'(006) ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'INSTANCE_ID'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'ORDER_ID'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'TIMESTAMP'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.
          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'ACTION_NAME'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.
*
          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'PERFORMED_BY'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          TRY.
              CLEAR lo_column.
              lo_column = lo_columns->get_column( columnname = 'TASK_STATUS'  ).
              lo_column->set_visible( abap_false ).
            CATCH cx_salv_not_found.
          ENDTRY.

          lo_log_tab->display( ).
        CATCH cx_salv_msg.
      ENDTRY.
    ENDIF.
  ENDIF.
ENDMODULE.
