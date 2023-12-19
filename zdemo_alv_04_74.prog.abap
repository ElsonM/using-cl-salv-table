************************************************************************
* Program:        ZDEMO_ALV_04_74                                      *
* Request ID:     RXXXXXX                                              *
* User ID:        ELSONMECO                                            *
* Date:           15.10.2017                                           *
* Description:    -                                                    *
************************************************************************
REPORT zdemo_alv_04_74.

************************************************************************
* CLASSES                                                              *
************************************************************************
CLASS cl_custom_alv DEFINITION.
  PUBLIC SECTION.
    METHODS constructor.
    METHODS display.

  PRIVATE SECTION.
    DATA alv TYPE REF TO cl_salv_table.
    DATA data_to_be_displayed TYPE STANDARD TABLE OF spfli.

    METHODS get_data_to_be_displayed.
    METHODS initialize_alv.
    METHODS customize_alv.
    METHODS enable_layout_settings.
    METHODS optimize_column_width.
    METHODS hide_client_column.
    METHODS set_departure_country_column.
    METHODS set_custom_toolbar.
    METHODS display_settings.
    METHODS set_aggregations.
    METHODS set_hotspot_for_carrid.
    METHODS set_event_handler.

    METHODS on_link_click          FOR EVENT link_click     OF cl_salv_events_table
      IMPORTING row column.
    METHODS on_custom_button_click FOR EVENT added_function OF cl_salv_events_table
      IMPORTING e_salv_function.

    METHODS get_airline_name_by_code
      IMPORTING row                 TYPE i
      RETURNING VALUE(airline_name) TYPE string.

    METHODS get_selected_flight
      RETURNING VALUE(selected_flight) TYPE spfli.

    METHODS call_change_flight_transaction
      IMPORTING selected_flight TYPE spfli.
ENDCLASS.

CLASS cl_custom_alv IMPLEMENTATION.
  METHOD constructor.
    get_data_to_be_displayed( ).
    initialize_alv( ).
    customize_alv( ).
  ENDMETHOD.

  METHOD get_data_to_be_displayed.
    SELECT * FROM spfli INTO TABLE data_to_be_displayed.
  ENDMETHOD.

  METHOD initialize_alv.
    TRY.
        DATA(lr_splitter) = NEW cl_gui_splitter_container(
          parent                  = cl_gui_container=>default_screen
          no_autodef_progid_dynnr = abap_true
          rows                    = 1
          columns                 = 1 ).

        DATA(lr_container) = lr_splitter->get_container( row = 1 column = 1 ).

        cl_salv_table=>factory(
          EXPORTING
            r_container = lr_container
          IMPORTING
            r_salv_table = alv
          CHANGING
            t_table = data_to_be_displayed ).
      CATCH cx_salv_msg INTO DATA(message).
        " error handling
    ENDTRY.
  ENDMETHOD.

  METHOD customize_alv.
    enable_layout_settings( ).
    optimize_column_width( ).
    hide_client_column( ).
    set_departure_country_column( ).
    set_custom_toolbar( ).
    display_settings( ).
    set_aggregations( ).
    set_hotspot_for_carrid( ).
    set_event_handler( ).
  ENDMETHOD.

  METHOD enable_layout_settings.
    DATA layout_settings TYPE REF TO cl_salv_layout.
    DATA layout_key TYPE salv_s_layout_key.

    layout_settings = alv->get_layout( ).

    layout_key-report = sy-repid.
    layout_settings->set_key( layout_key ).

    layout_settings->set_save_restriction( if_salv_c_layout=>restrict_none ).
    layout_settings->set_default( if_salv_c_bool_sap=>true ).
  ENDMETHOD.

  METHOD optimize_column_width.
    alv->get_columns( )->set_optimize( ).
  ENDMETHOD.

  METHOD hide_client_column.
    TRY.
        alv->get_columns( )->get_column( 'MANDT' )->set_visible( if_salv_c_bool_sap=>false ).
      CATCH cx_salv_not_found INTO DATA(not_found).
        " error handling
    ENDTRY.
  ENDMETHOD.

  METHOD set_departure_country_column.
    TRY.
        DATA(column) = alv->get_columns( )->get_column( 'COUNTRYFR' ).
        column->set_short_text( 'D. Country' ).
        column->set_medium_text( 'Dep. Country' ).
        column->set_long_text( 'Departure Country' ).
      CATCH cx_salv_not_found INTO DATA(not_found).
        " error handling
    ENDTRY.
  ENDMETHOD.

  METHOD set_custom_toolbar.
    alv->get_functions( )->set_all( ). "---> This line is removed

*    alv->set_screen_status(
*      report        = sy-repid                               " --> 'ZDEMO_ALV_03_74'
*      pfstatus      = 'SALV_TABLE_CUSTOM_01'
*      set_functions = alv->c_functions_all ).
  ENDMETHOD.

  METHOD display_settings.
    DATA(display_settings) = alv->get_display_settings( ).

    display_settings->set_striped_pattern( if_salv_c_bool_sap=>true ).
    display_settings->set_list_header( 'Flight Schedule' ).
  ENDMETHOD.

  METHOD set_aggregations.
    DATA(aggregations) = alv->get_aggregations( ).

    TRY.
        aggregations->add_aggregation(
        columnname = 'FLTIME'
        aggregation = if_salv_c_aggregation=>maximum ).
      CATCH cx_salv_data_error INTO DATA(data_error).
        " error handling
      CATCH cx_salv_not_found INTO DATA(not_found).
        " error handling
      CATCH cx_salv_existing INTO DATA(existing).
        " error handling
    ENDTRY.

    aggregations->set_aggregation_before_items( ).
  ENDMETHOD.

  METHOD display.
    alv->display( ).
  ENDMETHOD.

  METHOD set_hotspot_for_carrid.
    TRY.
        DATA(column) = CAST cl_salv_column_table(
          alv->get_columns( )->get_column( 'CARRID' ) ).

        column->set_cell_type( if_salv_c_cell_type=>hotspot ).
      CATCH cx_salv_not_found INTO DATA(not_found).
        " error handling
    ENDTRY.
  ENDMETHOD.

  METHOD set_event_handler.
    SET HANDLER on_link_click          FOR alv->get_event( ).
    SET HANDLER on_custom_button_click FOR alv->get_event( ).
  ENDMETHOD.

  METHOD on_link_click.
    DATA(airline_name) = get_airline_name_by_code( row ).

    IF airline_name IS NOT INITIAL.
      MESSAGE i398(00) WITH 'Selected Airline: ' '>>>' airline_name '<<<'.
    ENDIF.
  ENDMETHOD.

  METHOD on_custom_button_click.
    CASE e_salv_function.
      WHEN '&CHANGEFLI'.
        call_change_flight_transaction( get_selected_flight( ) ).
    ENDCASE.
  ENDMETHOD.

  METHOD get_airline_name_by_code.
    DATA(selected_row) = data_to_be_displayed[ row ].

    IF selected_row-carrid IS NOT INITIAL.
      SELECT SINGLE carrname FROM scarr INTO airline_name WHERE carrid = selected_row-carrid.
    ENDIF.
  ENDMETHOD.

  METHOD get_selected_flight.
    DATA(selected_rows) = alv->get_selections( )->get_selected_rows( ).
    TRY.
        DATA(row_number) = selected_rows[ 1 ].
        selected_flight  = data_to_be_displayed[ row_number ].
      CATCH cx_sy_itab_line_not_found INTO DATA(itab_line_not_found).
        MESSAGE e398(00) WITH 'No flight selected! Please, select a flight!'.
    ENDTRY.
  ENDMETHOD.

  METHOD call_change_flight_transaction.
    " SET PARAMETER ID 'CAR' FIELD selected_flight-carrid.
    " SET PARAMETER ID 'CON' FIELD selected_flight-connid.

    " CALL TRANSACTION 'YOUR TRANSACTION COMES HERE'.

    MESSAGE s398(00)
      WITH '[Selected Airline] ' selected_flight-carrid
           ', [Selected Flight Connection] ' selected_flight-connid.
  ENDMETHOD.
ENDCLASS.

************************************************************************
* CLASSES - END                                                        *
************************************************************************

************************************************************************
* MAIN PROGRAM *
************************************************************************
START-OF-SELECTION.
  DATA(custom_alv) = NEW cl_custom_alv( ).

  custom_alv->display( ).

  WRITE space.

************************************************************************
* MAIN PROGRAM - END                                                   *
************************************************************************
