FUNCTION-POOL ZCA_WIDISP.                   "MESSAGE-ID ..

* INCLUDE LZCA_WIDISPD...                    " Local class definition
CLASS lcl_handle_events DEFINITION DEFERRED.

*&SPWIZARD: FUNCTION CODES FOR TABSTRIP 'GS_WF_INFO'
CONSTANTS: BEGIN OF c_gs_wf_info,
             tab1 LIKE sy-ucomm VALUE 'INFO',
             tab2 LIKE sy-ucomm VALUE 'AGENTS',
             tab3 LIKE sy-ucomm VALUE 'NOTES',
             tab4 LIKE sy-ucomm VALUE 'ATTACH',
             tab5 LIKE sy-ucomm VALUE 'LOGS',
           END OF c_gs_wf_info.
*&SPWIZARD: DATA FOR TABSTRIP 'GS_WF_INFO'
CONTROLS:  gs_wf_info TYPE TABSTRIP.

CONSTANTS: gc_html      TYPE string VALUE '<HTML>',
           gc_htmlstart TYPE string VALUE '<HTML><BODY>',
           gc_htmlend   TYPE string VALUE '</HTML></BODY>'.

DATA: BEGIN OF g_gs_wf_info,
        subscreen   LIKE sy-dynnr,
        prog        LIKE sy-repid VALUE 'SAPLZCA_WIDISP',
        pressed_tab LIKE sy-ucomm VALUE c_gs_wf_info-tab1,
      END OF g_gs_wf_info.
DATA:      ok_code LIKE sy-ucomm.

DATA go_task  TYPE REF TO zcl_ca_wf_task_info.
DATA gv_title TYPE string.

" Task Header
DATA gs_task_detail TYPE zcl_ca_wf_task_info=>ty_task_detail.

" Task Info or Decsription
DATA gs_task_desc TYPE /iwwrk/s_tgw_description.
DATA go_info_cont TYPE REF TO cl_gui_custom_container.
DATA go_info_html TYPE REF TO cl_gui_html_viewer.
DATA gt_html_page TYPE STANDARD TABLE OF w3html.

" Task Agents
DATA gv_show_userid TYPE boolean.
DATA gt_agents TYPE zcl_ca_wf_task_info=>tt_agents.
DATA go_agents_cont TYPE REF TO cl_gui_custom_container.

" Task Comments
DATA gs_comment  TYPE string.
DATA go_comments_cont TYPE REF TO cl_gui_custom_container.
DATA go_comment_text TYPE REF TO cl_gui_textedit.

" Task Attachments
DATA gt_attachments TYPE zcl_ca_wf_task_info=>tt_attachments.
DATA go_attach_cont TYPE REF TO cl_gui_custom_container.
DATA go_attach_events TYPE REF TO lcl_handle_events.

" Task Logs
DATA gt_logs TYPE zcl_ca_wf_task_info=>tt_logs.
DATA go_log_cont TYPE REF TO cl_gui_custom_container.


*---------------------------------------------------------------------*
*       CLASS lcl_handle_events DEFINITION
*---------------------------------------------------------------------*
CLASS lcl_handle_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      on_double_click FOR EVENT double_click OF cl_salv_events_table
        IMPORTING row column,

      on_single_click FOR EVENT link_click OF cl_salv_events_table
        IMPORTING row column.
ENDCLASS.                    "lcl_handle_events DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_handle_events IMPLEMENTATION
*---------------------------------------------------------------------*
CLASS lcl_handle_events IMPLEMENTATION.
  METHOD on_double_click.
    PERFORM display_document USING row column.
  ENDMETHOD.                    "on_double_click

  METHOD on_single_click.
    PERFORM display_document USING row column.
  ENDMETHOD.                    "on_single_click
ENDCLASS.                    "lcl_handle_events IMPLEMENTATION
