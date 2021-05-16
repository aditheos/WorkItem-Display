*&---------------------------------------------------------------------*
*&  Include           LZCA_WIDISPI01
*&---------------------------------------------------------------------*

MODULE user_command_0010 INPUT.
  CASE ok_code.
    WHEN c_gs_wf_info-tab1.
      g_gs_wf_info-pressed_tab = c_gs_wf_info-tab1.
    WHEN c_gs_wf_info-tab2.
      g_gs_wf_info-pressed_tab = c_gs_wf_info-tab2.
    WHEN c_gs_wf_info-tab3.
      g_gs_wf_info-pressed_tab = c_gs_wf_info-tab3.
    WHEN c_gs_wf_info-tab4.
      g_gs_wf_info-pressed_tab = c_gs_wf_info-tab4.
    WHEN c_gs_wf_info-tab5.
      g_gs_wf_info-pressed_tab = c_gs_wf_info-tab5.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.
ENDMODULE.
