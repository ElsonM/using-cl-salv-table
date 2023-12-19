************************************************************************
* Program:        ZDEMO_ALV05                                          *
* Request ID:     RXXXXXX                                              *
* User ID:        ELSONMECO                                            *
* Date:           01.10.2017                                           *
* Description:    -                                                    *
************************************************************************
REPORT zdemo_alv05. "Displaying the standart toolbar

************************************************************************
* GLOBAL DATA DEFINITIONS                                              *
************************************************************************

*----------------------------------------------------------------------*
* INCLUDE - definitions                                                *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* CONSTANT - definitions                                               *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TYPE - definitions                                                   *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* DDIC - TABLE / STRUCTURE / VIEW definitions                          *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* STRUCTURE definitions                                                *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* RANGE definitions                                                    *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* REFERENCE definitions                                                *
*----------------------------------------------------------------------*
DATA alv     TYPE REF TO cl_salv_table.
DATA columns TYPE REF TO cl_salv_columns_table.
DATA column  TYPE REF TO cl_salv_column.

*----------------------------------------------------------------------*
* INTERNAL TABLE definitions                                           *
*----------------------------------------------------------------------*
DATA flight_schedule TYPE STANDARD TABLE OF spfli.

*----------------------------------------------------------------------*
* OTHER GLOBAL DATA definitions                                        *
*----------------------------------------------------------------------*

************************************************************************
* GLOBAL DATA DEFINITIONS - END                                        *
************************************************************************

************************************************************************
* SELECTION SCREENS                                                    *
************************************************************************

************************************************************************
* SELECTION SCREENS - END                                              *
************************************************************************

************************************************************************
* EVENTS                                                               *
************************************************************************

*----------------------------------------------------------------------*
* INITIALIZATON event                                                  *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST FOR event                       *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* START-OF-SELECTION event                                             *
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM get_flight_schedule.
  PERFORM initialize_alv.
  PERFORM display_alv.

*----------------------------------------------------------------------*
* END-OF-SELECTION event                                               *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* AT LINE-SELECTION event                                              *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* AT USER-COMMAND event                                                *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* TOP-OF-PAGE event                                                    *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* END-OF-PAGE event                                                    *
*----------------------------------------------------------------------*

************************************************************************
* EVENTS - END                                                         *
************************************************************************

************************************************************************
* SUBROUTINES                                                          *
************************************************************************

*&---------------------------------------------------------------------*
FORM get_flight_schedule.
*&---------------------------------------------------------------------*

  SELECT * FROM spfli INTO TABLE flight_schedule UP TO 100 ROWS.

ENDFORM.                    "GET_FLIGHT_SCHEDULE

*&---------------------------------------------------------------------*
FORM initialize_alv.
*&---------------------------------------------------------------------*

  DATA message   TYPE REF TO cx_salv_msg.

  TRY.
      cl_salv_table=>factory(
      IMPORTING
        r_salv_table = alv
      CHANGING
        t_table      = flight_schedule ).

      columns = alv->get_columns( ).

      PERFORM enable_layout_settings.
      PERFORM optimize_column_width.
      PERFORM hide_client_column.
      PERFORM set_departure_country_column.
      PERFORM set_toolbar.
      "...
      "PERFORM setting_n.

    CATCH cx_salv_msg INTO message.
      "Error handling
  ENDTRY.

ENDFORM.                    "INITIALIZE_ALV

*&---------------------------------------------------------------------*
FORM display_alv.
*&---------------------------------------------------------------------*

  alv->display( ).

ENDFORM.                    "DISPLAY_ALV

*&---------------------------------------------------------------------*
FORM enable_layout_settings.
*&---------------------------------------------------------------------*

  DATA layout_settings TYPE REF TO cl_salv_layout.
  DATA layout_key      TYPE salv_s_layout_key.

  layout_settings = alv->get_layout( ).

  layout_key-report = sy-repid.

  layout_settings->set_key( layout_key ).
  layout_settings->set_save_restriction( if_salv_c_layout=>restrict_none ).

ENDFORM.                    "ENABLE_LAYOUT_SETTINGS

*&---------------------------------------------------------------------*
FORM optimize_column_width.
*&---------------------------------------------------------------------*

  columns->set_optimize( ).

ENDFORM.                    "OPTIMIZE_COLUMN_WIDTH

*&---------------------------------------------------------------------*
FORM hide_client_column.
*&---------------------------------------------------------------------*

  DATA not_found TYPE REF TO cx_salv_not_found.

  TRY.
      column = columns->get_column( 'MANDT' ).
      column->set_visible( if_salv_c_bool_sap=>false ).
    CATCH cx_salv_not_found INTO not_found.
      "Error handling
  ENDTRY.

ENDFORM.                    "HIDE_CLIENT_COLUMN

*&---------------------------------------------------------------------*
FORM set_departure_country_column.
*&---------------------------------------------------------------------*

  DATA not_found TYPE REF TO cx_salv_not_found.

  TRY.
      column = columns->get_column( 'COUNTRYFR' ).
      column->set_short_text( 'D. Country' ).
      column->set_medium_text( 'Dep. Country' ).
      column->set_long_text( 'Departure Country' ).
    CATCH cx_salv_not_found INTO not_found.
      "Error handling
  ENDTRY.

ENDFORM.                    "SET_DEPARTURE_COUNTRY_COLUMN

*&---------------------------------------------------------------------*
FORM set_toolbar.
*&---------------------------------------------------------------------*

  DATA functions TYPE REF TO cl_salv_functions_list.

  functions = alv->get_functions( ).
  functions->set_all( ).

ENDFORM.                    "SET_TOOLBAR

************************************************************************
* SUBROUTINES - END                                                    *
************************************************************************
