" -----------------------------------------------------------------------------------------------------------------------
" Copyright 2024 Google LLC                                                                                            -
" ABAP SDK for Google Cloud is made available as "Software" under the agreement governing your use of                  -
" Google Cloud Platform including the Service Specific Terms available at                                              -
"                                                                                                                      -
" https://cloud.google.com/terms/service-terms                                                                         -
"                                                                                                                      -
" Without limiting the generality of the above terms, you may not modify or distribute ABAP SDK for Google Cloud       -
" without express written permission from Google.                                                                      -
" -----------------------------------------------------------------------------------------------------------------------
CLASS zcl_cs_translate_doc_in_batch DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_cs_translate_doc_in_batch IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    " Data Declarations
    DATA lv_p_projects_id  TYPE string.
    DATA lv_p_locations_id TYPE string.
    DATA ls_input          TYPE /goog/cl_translation_v3=>ty_003.

    TRY.
        " Open HTTP Connection
        " Pass the configured client key
        DATA(lo_translate) = NEW /goog/cl_translation_v3( iv_key_name = 'TRANSLATE_DEMO' ).

        " Populate the data that needs to be passed to the API
        " Derive project id
        lv_p_projects_id  = lo_translate->gv_project_id.
        " Pass location id, us-central1 is used as an example
        lv_p_locations_id = 'us-central1'.

        " Passing two target language codes (BCP-47 codes)
        " Input URI and Output URI contain example cloud storage bucket names
        ls_input = VALUE #(
            source_language_code  = 'en-US'
            target_language_codes = VALUE #( ( `es-ES` )
                                             ( `fr-FR` ) )
            input_configs         = VALUE #( ( gcs_source = VALUE #( input_uri = 'gs://documents/batch' ) ) )
            output_config         = VALUE #(
                gcs_destination = VALUE #( output_uri_prefix = 'gs://documents_output/' ) ) ).

        " Call the API
        lo_translate->batch_translate_document_lo( EXPORTING iv_p_projects_id  = lv_p_projects_id
                                                             iv_p_locations_id = lv_p_locations_id
                                                             is_input          = ls_input
                                                   IMPORTING es_output         = DATA(ls_output)
                                                             ev_ret_code       = DATA(lv_ret_code)
                                                             ev_err_text       = DATA(lv_err_text)
                                                             es_err_resp       = DATA(ls_err_resp) ).
        IF /goog/cl_http_client=>is_success( lv_ret_code ).
          " This returns a long running operation id as glossary creation is adhoc
          " You can use the LRO ID to poll and check the status of the operation
          out->write( |LRO ID: { ls_output-name }| ).
        ELSE.
          out->write( | Error occurred: { lv_err_text }| ).
        ENDIF.

        " Close HTTP Connection
        lo_translate->close( ).

      CATCH /goog/cx_sdk INTO DATA(lo_sdk_excp).
        lv_err_text = lo_sdk_excp->get_text( ).
        out->write( |Exception occurred: { lv_err_text } | ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
