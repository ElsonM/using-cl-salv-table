*----------------------------------------------------------------------*
* Subtotals in ALV report using factory class CL_SALV_TABLE            *
*----------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdemo_subtotals.

*----------------------------------------------------------------------*
*       CLASS lcl_sflight DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_sflight DEFINITION.

  PUBLIC SECTION.
    TYPES: BEGIN OF lty_sflight,
             carrid	   TYPE s_carr_id,
             connid	   TYPE s_conn_id,
             fldate	   TYPE s_date,
             price     TYPE s_price,
             currency	 TYPE s_currcode,
             planetype TYPE s_planetye,
             seatsmax	 TYPE s_seatsmax,
             seatsocc	 TYPE s_seatsocc,
           END OF lty_sflight.

    METHODS:
      get_sflight_data,
      get_alv_instance,
      display.

    DATA: lo_alv     TYPE REF TO cl_salv_table,
          gt_sflight TYPE STANDARD TABLE OF lty_sflight.

ENDCLASS.                    "lcl_sflight DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_sflight IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_sflight IMPLEMENTATION.

* Get SFLIGHT data
  METHOD get_sflight_data.

    SELECT carrid connid fldate price currency planetype seatsmax
           seatsocc INTO TABLE me->gt_sflight
                    FROM sflight
                    WHERE carrid IN ('AA', 'JL' ).

  ENDMETHOD.

* Get ALV instance
  METHOD get_alv_instance.

    TRY.
        CALL METHOD cl_salv_table=>factory
          IMPORTING
            r_salv_table = me->lo_alv
          CHANGING
            t_table      = gt_sflight.
      CATCH cx_salv_msg.
    ENDTRY.

  ENDMETHOD.

* Display ALV
  METHOD display.

    CALL METHOD lo_alv->display.

  ENDMETHOD.

ENDCLASS.                    "lcl_sflight IMPLEMENTATION

START-OF-SELECTION.

  DATA: lo_cl_sflight   TYPE REF TO lcl_sflight,
        lo_aggregations TYPE REF TO cl_salv_aggregations,
        lo_sorts        TYPE REF TO cl_salv_sorts.

  CREATE OBJECT lo_cl_sflight.

* Get the Data for ALV report
  lo_cl_sflight->get_sflight_data( ).

* Get ALV instance
  lo_cl_sflight->get_alv_instance( ).

*/--------------------------- Add Totals and Subtotals ----------------------*
*// 1.Get Aggregation object of the ALV
  CALL METHOD lo_cl_sflight->lo_alv->get_aggregations
    RECEIVING
      value = lo_aggregations.

*// 2.Specify tht column name for totals
  TRY.
      CALL METHOD lo_aggregations->add_aggregation
        EXPORTING
          columnname  = 'PRICE'
          aggregation = if_salv_c_aggregation=>total.
    CATCH cx_salv_data_error .
    CATCH cx_salv_not_found .
    CATCH cx_salv_existing .
  ENDTRY.


*// Sorting
**// 3. Get Sorting Object of the ALV
  CALL METHOD lo_cl_sflight->lo_alv->get_sorts
    RECEIVING
      value = lo_sorts.

**// 4.Specify the column for sorting
  TRY.
      CALL METHOD lo_sorts->add_sort
        EXPORTING
          columnname = 'CARRID'
*         position   =
          sequence   = if_salv_c_sort=>sort_up
          subtotal   = if_salv_c_bool_sap=>true.  "<<--Subtotals flag for the Airline column
*        group      = IF_SALV_C_SORT=>GROUP_NONE
*        obligatory = IF_SALV_C_BOOL_SAP=>FALSE.
    CATCH cx_salv_not_found.
    CATCH cx_salv_existing.
    CATCH cx_salv_data_error.
  ENDTRY.

* Display ALV report
  lo_cl_sflight->display( ).
