FUNCTION ZCA_WI_DISPLAY.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_WORKITEM_ID) TYPE  SWW_WIID
*"     REFERENCE(IV_TITLE) TYPE  STRING OPTIONAL
*"     REFERENCE(IV_SHOW_USERID) TYPE  BOOLEAN DEFAULT 'X'
*"--------------------------------------------------------------------
  IF NOT iv_title IS INITIAL.
    CLEAR gv_title.
    gv_title = iv_title.
  ENDIF.
  CLEAR:go_task,
        go_info_cont, go_info_html,
        go_agents_cont,
        go_comments_cont, go_comment_text,
        go_attach_cont, go_attach_events,
        go_log_cont.

  " Instantitate Task Info
  CREATE OBJECT go_task.

  " Set Work Item
  TRY .
      go_task->/iwwrk/if_tgw_task~set_workitem_id(
        EXPORTING
          iv_workitem_id =  iv_workitem_id           " Work item ID
      ).
    CATCH /iwbep/cx_mgw_busi_exception.
      RETURN.
  ENDTRY.

  " Get Task Details
  CLEAR gs_task_detail.
  go_task->get_task_detail(
    IMPORTING
      es_task_detail = gs_task_detail                 " Task Gateway: Task Header
  ).

  " Get Task Description
  CLEAR: gs_task_desc, gt_html_page.
  go_task->/iwwrk/if_tgw_task~read_task_description(
    IMPORTING
      es_wi_description = gs_task_desc  " Description structure for Task GW
  ).
  IF gs_task_desc-description_html NS gc_html.
    CONCATENATE gc_htmlstart
                gs_task_desc-description_html
                gc_htmlend
           INTO gs_task_desc-description_html.
  ENDIF.
  CALL FUNCTION 'SOTR_SERV_STRING_TO_TABLE'
    EXPORTING
      text        = gs_task_desc-description_html
      line_length = 255
    TABLES
      text_tab    = gt_html_page.

  " Get Task Agents
  CLEAR: gv_show_userid, gt_agents.
  gv_show_userid = iv_show_userid.
  go_task->get_workflow_agents(
    IMPORTING
      et_agents = gt_agents              " Agents
  ).

  " Get Comments
  CLEAR: gs_comment.
  go_task->get_comments(
    IMPORTING
      es_comment  = gs_comment           " Comment
  ).

  " Get Attachments
  CLEAR: gt_attachments.
  go_task->get_attachments(
    IMPORTING
      et_attachments = gt_attachments    " Attachments
  ).

  " Get Logs
  CLEAR: gt_logs.
  go_task->get_logs(
    IMPORTING
      et_logs = gt_logs                  " Logs
  ).

  " Dispaly Workitem
  CALL SCREEN '0010'.

ENDFUNCTION.
