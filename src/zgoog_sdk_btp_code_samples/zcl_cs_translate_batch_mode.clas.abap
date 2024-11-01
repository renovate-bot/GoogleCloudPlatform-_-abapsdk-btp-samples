" --------------------------------------------------------------------
"  Copyright 2024 Google LLC                                         -
"                                                                    -
"  Licensed under the Apache License, Version 2.0 (the "License");   -
"  you may not use this file except in compliance with the License.  -
"  You may obtain a copy of the License at                           -
"      https://www.apache.org/licenses/LICENSE-2.0                   -
"  Unless required by applicable law or agreed to in writing,        -
"  software distributed under the License is distributed on an       -
"  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,      -
"  either express or implied.                                        -
"  See the License for the specific language governing permissions   -
"  and limitations under the License.                                -
" --------------------------------------------------------------------
CLASS zcl_cs_translate_batch_mode DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.



CLASS ZCL_CS_TRANSLATE_BATCH_MODE IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    " Data Declarations
    DATA lv_p_projects_id  TYPE string.
    DATA lv_p_locations_id TYPE string.
    DATA lv_input_uri      TYPE string.
    DATA lv_output_uri     TYPE string.
    DATA ls_input          TYPE /goog/cl_translation_v3=>ty_004.
    DATA ls_ip_cnf         TYPE /goog/cl_translation_v3=>ty_029.
    DATA lt_ip_cnf         TYPE /goog/cl_translation_v3=>ty_t_029.
    DATA ls_op_cnf         TYPE /goog/cl_translation_v3=>ty_043.
    DATA lv_folder         TYPE string.

    TRY.
        " Open HTTP Connection
        " Pass the configured client key, TRANSLATE_DEMO is used as example, replace it with actual value
        DATA(lo_translate) = NEW /goog/cl_translation_v3( iv_key_name = 'TRANSLATE_DEMO' ).

        " Populate the data that needs to be passed to the API
        " Derive project id
        lv_p_projects_id  = lo_translate->gv_project_id.

        " Pass location id, us-central1 is used as an example, repalce it with actual value
        lv_p_locations_id = 'us-central1'.

        "TODO: Provide storage bucket paths for uri values
        "For source provide the complete file path including storage bucket, for target provide the storage bucket name
        "lv_input_uri =
        "lv_output_uri =

        "The values passed below for mime_type, source and target language codes are as examples.
        "Replace them with actual values
        ls_input = VALUE #( input_configs         = VALUE #(
                                ( gcs_source = VALUE #( input_uri = lv_input_uri )
                                  mime_type  = 'text/plain' ) )
                            output_config         = VALUE #(
                                gcs_destination = VALUE #( output_uri_prefix = lv_output_uri )  )
                            source_language_code  = `en`
                            target_language_codes = VALUE #( ( `es` ) ) ).

        " Call the API
        lo_translate->batch_translate_text_locati( EXPORTING iv_p_projects_id  = lv_p_projects_id
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
