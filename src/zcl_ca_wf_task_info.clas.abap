class ZCL_CA_WF_TASK_INFO definition
  public
  inheriting from /IWWRK/CL_TGW_GEN_TASK
  final
  create public .

public section.

  types:
    BEGIN OF ty_task_detail.
        INCLUDE TYPE /iwwrk/s_tgw_task.
        TYPES:   created_byname TYPE ad_namtext,
        status_text    TYPE val_text,
        priority_text  TYPE val_text,
        created_date   TYPE sy-datum,
        created_time   TYPE sy-uzeit,
        due_date       TYPE sy-datum,
        due_time       TYPE sy-uzeit,
      END OF ty_task_detail .
  types:
    BEGIN OF ty_agents,
        userid   TYPE  syuname,
        fullname TYPE  ad_namtext,
      END OF ty_agents .
  types:
    tt_agents TYPE STANDARD TABLE OF ty_agents .
  types:
    BEGIN OF ty_attachments.
        INCLUDE TYPE /iwwrk/s_tgw_attachments.
      TYPES:
        created_byname TYPE ad_namtext,
        created_date   TYPE sydatum,
        created_time   TYPE syuzeit,
        ainstid        TYPE  sibfboriid,
        atypeid        TYPE  sibftypeid,
        acatid         TYPE  sibfcatid,
        icon           TYPE icon_d,
      END OF ty_attachments .
  types:
    tt_attachments TYPE STANDARD TABLE OF ty_attachments .
  types:
    BEGIN OF ty_logs.
        INCLUDE TYPE /iwwrk/s_tgw_log_entry.
      TYPES:
        created_byname TYPE ad_namtext,
        created_date   TYPE sydatum,
        created_time   TYPE syuzeit,
      END OF ty_logs .
  types:
    tt_logs TYPE STANDARD TABLE OF ty_logs .

  methods GET_WORKFLOW_AGENTS
    exporting
      !ET_AGENTS type TT_AGENTS .
  methods GET_TASK_DETAIL
    exporting
      !ES_TASK_DETAIL type TY_TASK_DETAIL .
  methods GET_COMMENTS
    exporting
      !ES_COMMENT type STRING .
  methods GET_ATTACHMENTS
    exporting
      !ET_ATTACHMENTS type TT_ATTACHMENTS .
  methods GET_LOGS
    exporting
      !ET_LOGS type TT_LOGS .

  methods /IWWRK/IF_TGW_TASK~SET_WORKITEM_ID
    redefinition .
protected section.

  methods GET_STATUS_TEXT
    importing
      !IV_STATUS type /IWWRK/WF_WI_STATUS
    exporting
      !EV_STATUS_TEXT type VAL_TEXT .
  methods GET_PRIORITY_TEXT
    importing
      !IV_PRIORITY type SWW_PRIO
    exporting
      !EV_PRIORITY_TEXT type VAL_TEXT .
  methods GET_USERNAME
    importing
      !IV_USERID type UNAME optional
      !IT_USER type TSWHACTOR optional
    exporting
      !EV_USERNAME type AD_NAMTEXT
      !ET_FULLNAME type TT_AGENTS .
private section.
ENDCLASS.



CLASS ZCL_CA_WF_TASK_INFO IMPLEMENTATION.


  METHOD /IWWRK/IF_TGW_TASK~SET_WORKITEM_ID.
    DATA:
      ls_target_t100    TYPE scx_t100key,
      lx_busi_exception TYPE REF TO /iwbep/cx_mgw_busi_exception.

    CLEAR: mo_wi_runtime.

    mv_workitem_id = iv_workitem_id.
    mt_filter_select_option = it_filter_select_options.
    mt_order = it_order.
    ms_paging = is_paging.
    mv_action = iv_action.
    CLEAR ms_wi_header.

    mo_wi_runtime  =  get_wi_rt_instance( ).
  ENDMETHOD.


  METHOD GET_ATTACHMENTS.
    INCLUDE <icon>.
    DATA: lv_user TYPE syuname.
    DATA: lt_attachments_obj     TYPE          sibflporbt,
          ls_attachment_obj      TYPE          sibflporb,
          ls_wi_attachment       LIKE LINE OF  et_attachments,
          ls_attachment_supports TYPE          /iwwrk/cl_tgw_util=>ty_attachment_supports,
          lt_attachment_supports TYPE          /iwwrk/cl_tgw_util=>tt_attachment_supports,
          ls_doc_data            TYPE          ty_doc_meta,
          lv_system_timezone     TYPE          timezone,
          lv_encode              TYPE          string,
          lv_doc_id              TYPE          string,
          lv_task_status         TYPE          sww_wistat,
          lv_return_code         TYPE          sy-subrc.


    lt_attachments_obj = get_attachments_obj( ).

    ls_wi_attachment-instance_id = /iwwrk/if_tgw_task~get_workitem_id( ).

    lv_task_status = /iwwrk/if_tgw_task~read_task_status( ).

    lt_attachment_supports = /iwwrk/cl_tgw_util=>get_attachment_supports( iv_workitem_id = ls_wi_attachment-instance_id
                                                                          iv_task_status = lv_task_status
                                                                          it_attachment_obj = lt_attachments_obj ).

    lv_system_timezone = /iwwrk/cl_mgw_workflow_rt_util=>get_system_timezone( ).

    LOOP AT lt_attachments_obj INTO ls_attachment_obj.

      lv_doc_id = ls_attachment_obj-instid.

      get_document_data( EXPORTING  iv_doc_id        = lv_doc_id
                                    iv_no_content    = abap_true
                                    iv_mime_info     = abap_true
                         IMPORTING  es_doc_data      = ls_doc_data
                                    ev_return_code   = lv_return_code ).
      CHECK lv_return_code = 0.
      CHECK ls_doc_data-doc_size > 0.
      CHECK /iwwrk/cl_mgw_workflow_rt_util=>is_comment( i_object_description = ls_doc_data-obj_descr ) EQ abap_false.

      lv_encode                     = lv_doc_id.
      ls_wi_attachment-id           = cl_http_utility=>if_http_utility~encode_utf8( lv_encode ).
      ls_wi_attachment-filename    = ls_doc_data-file_name.
      ls_wi_attachment-mime_type   = ls_doc_data-mime_type.
      ls_wi_attachment-created_by  = ls_doc_data-create_name.
      ls_wi_attachment-created_date  = ls_doc_data-create_date.
      ls_wi_attachment-created_time  = ls_doc_data-create_time.
      ls_wi_attachment-ainstid = ls_attachment_obj-instid.
      ls_wi_attachment-atypeid = ls_attachment_obj-typeid.
      ls_wi_attachment-acatid = ls_attachment_obj-catid.
      ls_wi_attachment-icon = icon_attachment.
      CLEAR lv_user.
      lv_user = ls_wi_attachment-created_by.
      get_username(
        EXPORTING
          iv_userid   = lv_user                          " UserID
        IMPORTING
          ev_username = ls_wi_attachment-created_byname  " Full Name
      ).
      ls_wi_attachment-filesize    = ls_doc_data-doc_size.
      CONDENSE ls_wi_attachment-filesize.
      ls_wi_attachment-created_at  = /iwwrk/cl_mgw_workflow_rt_util=>build_datetime( iv_date = ls_doc_data-create_date
                                                                                     iv_time = ls_doc_data-create_time
                                                                                     iv_timezone = lv_system_timezone ).

      READ TABLE lt_attachment_supports INTO ls_attachment_supports WITH KEY object_id = ls_attachment_obj.
      IF sy-subrc IS INITIAL.
        ls_wi_attachment-attachment_supports = ls_attachment_supports-attachment_supports.
      ELSE.
        CLEAR ls_wi_attachment-attachment_supports.
      ENDIF.

      APPEND ls_wi_attachment TO et_attachments.
    ENDLOOP.

  ENDMETHOD.


  METHOD GET_COMMENTS.
    DATA lv_user TYPE syuname.
    DATA lv_text TYPE string.
    DATA lv_date TYPE char10.
    DATA lv_time TYPE char8.

    /iwwrk/if_tgw_task~query_comments(
      IMPORTING
        et_wi_comments = DATA(lt_comments)      " Comment table type for Task GW
    ).

    SORT lt_comments BY created_at DESCENDING.

    " Comments
    LOOP AT lt_comments INTO DATA(ls_comment).
      IF sy-tabix EQ 0.
        es_comment = ls_comment-text.
      ELSE.
        CONCATENATE es_comment ls_comment-text INTO es_comment
          SEPARATED BY cl_abap_char_utilities=>cr_lf.
      ENDIF.

      CLEAR lv_user.
      lv_user = ls_comment-created_by.
      get_username(
        EXPORTING
          iv_userid   = lv_user                   " UserID
        IMPORTING
          ev_username = DATA(lv_username)  " Full Name
      ).

      " Creation
      CLEAR: lv_date, lv_time.
      CONVERT TIME STAMP ls_comment-created_at TIME ZONE sy-zonlo
         INTO DATE DATA(lv_created_on) TIME DATA(lv_created_at).
      WRITE lv_created_on TO lv_date.
      WRITE lv_created_at TO lv_time.

      CLEAR lv_text.
      lv_text = |@ { lv_username } ( { lv_date } { lv_time } )|.
      CONCATENATE es_comment lv_text INTO es_comment
        SEPARATED BY cl_abap_char_utilities=>cr_lf.

      CLEAR lv_text.
      lv_text = |___________________|.
      CONCATENATE es_comment lv_text INTO es_comment
        SEPARATED BY cl_abap_char_utilities=>cr_lf.

      CLEAR lv_text.
      CONCATENATE es_comment lv_text INTO es_comment
        SEPARATED BY cl_abap_char_utilities=>cr_lf.
    ENDLOOP.
  ENDMETHOD.


  METHOD GET_LOGS.
    /iwwrk/if_tgw_task~query_logging(
      IMPORTING
        et_wi_logs = DATA(lt_logs)                 " Logging entry for task BWF
    ).

    SORT lt_logs BY timestamp DESCENDING.
    LOOP AT lt_logs INTO DATA(ls_log).
      APPEND INITIAL LINE TO et_logs ASSIGNING FIELD-SYMBOL(<lfs_log>).
      <lfs_log> = CORRESPONDING #( ls_log ).

      get_username(
        EXPORTING
          iv_userid   = ls_log-performed_by          " UserID
        IMPORTING
          ev_username = <lfs_log>-created_byname  " Full Name
      ).

      " Creation
      CONVERT TIME STAMP ls_log-timestamp TIME ZONE sy-zonlo
         INTO DATE <lfs_log>-created_date TIME <lfs_log>-created_time.
    ENDLOOP.
  ENDMETHOD.


  METHOD GET_PRIORITY_TEXT.
    SELECT SINGLE text
      FROM zca_i_wfprio_vh
     WHERE value = @iv_priority
      INTO @ev_priority_text.
  ENDMETHOD.


  METHOD GET_STATUS_TEXT.
    SELECT SINGLE text
      FROM zca_i_wfstatus_vh
     WHERE value = @iv_status
      INTO @ev_status_text.
  ENDMETHOD.


  METHOD GET_TASK_DETAIL.
    DATA lv_file_path     TYPE string.
    DATA ls_defguid       TYPE swf_stguid.
    DATA lv_user          TYPE syuname.

    " Get Task Detail
    es_task_detail-inst_id = /iwwrk/if_tgw_task~get_workitem_id( ).
    get_wi_header(     IMPORTING es_wi_header = DATA(ls_wi_header) ).
    get_wi_details(    IMPORTING  es_wi_detail = DATA(ls_wi_detail) ).
    get_wi_top_header( IMPORTING   es_wi_top_header = DATA(ls_wi_top_header)
                                   ev_return_code   = DATA(lv_return_code) ).

    es_task_detail-task_def_id = ls_wi_detail-wi_rh_task.
    get_step_subject_text( IMPORTING ev_wf_step_text = DATA(lv_task_subject) ).
    es_task_detail-task_def_name = lv_task_subject.

    es_task_detail-task_title = me->get_wi_title( ).

    es_task_detail-priority = ls_wi_detail-wi_prio.
    es_task_detail-status = ls_wi_detail-wi_stat.
    es_task_detail-created_on = /iwwrk/cl_mgw_workflow_rt_util=>build_datetime( iv_date = ls_wi_detail-wi_cd iv_time = ls_wi_detail-wi_ct ).
    es_task_detail-created_by = ls_wi_top_header-wi_cruser.
    es_task_detail-processor = ls_wi_header-wi_aagent.
    es_task_detail-start_dl = /iwwrk/cl_mgw_workflow_rt_util=>build_datetime( iv_date = ls_wi_detail-wi_lsd iv_time = ls_wi_detail-wi_lst ).
    es_task_detail-comp_dl = /iwwrk/cl_mgw_workflow_rt_util=>build_datetime( iv_date = ls_wi_detail-wi_led iv_time = ls_wi_detail-wi_let ).
    es_task_detail-has_comments = /iwwrk/if_tgw_task~has_comments( ).
    es_task_detail-has_attach = /iwwrk/if_tgw_task~has_attachments( ).

    /iwwrk/if_tgw_task~query_potential_owners( IMPORTING  et_wi_potential_owners = DATA(lt_wi_potantial_owners)
                                                          ev_return_code         = lv_return_code ).
    IF lv_return_code EQ /iwwrk/if_mgw_workflow_const=>gcs_result_code-success AND lt_wi_potantial_owners IS NOT INITIAL.
      es_task_detail-has_p_owners = abap_true.
    ENDIF.

    get_wi_node_def( IMPORTING  ev_workflow_id = DATA(lv_wf_id)
                                ev_version     = DATA(lv_wf_version)
                                ev_step_id     = DATA(lv_wf_step_id) ).

    " Get relevant version of step customizing in combined key
    DATA(lv_wfv_id) = /iwwrk/cl_wf_step_config=>get_step_config_version(
    iv_wfd_id  = CONV #( lv_wf_id )
    iv_version = lv_wf_version
    iv_step_id = lv_wf_step_id
  ).

    lv_file_path = /iwwrk/cl_wf_step_config=>get_step_icon( iv_wf_id   = lv_wfv_id
                                                            iv_step_id = lv_wf_step_id ).

    IF lv_file_path IS NOT INITIAL.
      CALL METHOD /iwwrk/cl_wf_mime_util=>get_file_properties
        EXPORTING
          iv_file_path = lv_file_path
        IMPORTING
          ev_mime_type = es_task_detail-mime_type.
    ENDIF.

    ls_defguid = ls_wi_header-def_guid.
    es_task_detail-task_def_id_ext = /iwwrk/cl_mgw_workflow_rt_util=>build_task_def_id_ext( iv_task_def_id = ls_wi_detail-wi_rh_task
                                                                                            iv_wf_id = lv_wf_id
                                                                                            iv_wf_step_id = lv_wf_step_id
                                                                                            iv_node_type = ls_defguid-nodetype ).

    es_task_detail-forwarding_user = ls_wi_header-wi_forw_by.
    es_task_detail-task_supports = get_task_supports( ).


    CLEAR lv_user.
    lv_user = es_task_detail-created_by.
    get_username(
      EXPORTING
        iv_userid   = lv_user                       " UserID
      IMPORTING
        ev_username = es_task_detail-created_byname " Full Name
    ).
    es_task_detail-created_date = ls_wi_detail-wi_cd.
    es_task_detail-created_time = ls_wi_detail-wi_ct.
    es_task_detail-due_date = ls_wi_detail-wi_led.
    es_task_detail-due_time = ls_wi_detail-wi_let.
    es_task_detail-status_text = ls_wi_detail-wi_stattext.
    es_task_detail-priority_text = ls_wi_detail-wi_priotext.

  ENDMETHOD.


  METHOD GET_USERNAME.
    IF NOT iv_userid IS INITIAL.
      CLEAR ev_username.
      SELECT SINGLE fullname
        FROM zca_i_username_vh
       WHERE userid = @iv_userid
        INTO @ev_username.
    ELSEIF NOT it_user IS INITIAL.
      CLEAR et_fullname.
      SELECT userid, fullname
        FROM zca_i_username_vh
         FOR ALL ENTRIES IN @it_user
       WHERE userid = @it_user-objid
        INTO TABLE @et_fullname.
    ENDIF.
  ENDMETHOD.


  METHOD GET_WORKFLOW_AGENTS.
    DATA: lt_agents TYPE tswhactor.
    " Get Task Detail
    /iwwrk/if_tgw_task~read_task_detail(
      IMPORTING
        es_task_detail = DATA(ls_task_detail)     " Task Gateway: Task Header
    ).

    IF ls_task_detail-processor IS INITIAL.
      CLEAR lt_agents.
      " Get Agents
      CALL FUNCTION 'RH_WI_ORGTASK_READ'
        EXPORTING
          wi_id       = mv_workitem_id
        TABLES
          wi_agents   = lt_agents
        EXCEPTIONS
          read_failed = 1
          OTHERS      = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ELSE.
        get_username(
          EXPORTING
            it_user     = lt_agents                 " User Table
          IMPORTING
            et_fullname = et_agents                 " Full Name Table
        ).
      ENDIF.
    ELSE.
      APPEND INITIAL LINE TO et_agents ASSIGNING FIELD-SYMBOL(<lfs_agent>).
      <lfs_agent>-userid = ls_task_detail-processor.
      get_username(
        EXPORTING
          iv_userid   = <lfs_agent>-userid    " UserID
        IMPORTING
          ev_username = <lfs_agent>-fullname  " Full Name
      ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
