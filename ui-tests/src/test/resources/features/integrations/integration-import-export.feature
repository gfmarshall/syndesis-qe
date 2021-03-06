# @sustainer: mcada@redhat.com

@integration-import-export
Feature: Integration - Import Export

  Background: Clean application state
    Given clean application state
    And log into the Syndesis

#
#  1. integration-import both methods, for investigation one of them use integration-import-export_backup.feature
#
  @integration-import-export-classic-and-dnd
  Scenario: Import and export both flows

    Given created connections
      | Twitter    | Twitter Listener | Twitter Listener | SyndesisQE Twitter listener account |
      | Salesforce | QE Salesforce    | QE Salesforce    | SyndesisQE salesforce test          |

    # create integration
    When navigate to the "Home" page
    And click on the "Create Integration" button to create a new integration.
    And check visibility of visual integration editor
    Then check that position of connection to fill is "Start"

    # select twitter connection
    When select the "Twitter Listener" connection
    And select "Mention" integration action
    Then check that position of connection to fill is "Finish"

    # select salesforce connection
    When select the "QE Salesforce" connection
    And select "Create or update record" integration action
    And select "Contact" from "sObjectName" dropdown
    And click on the "Next" button
    And select "TwitterScreenName" from "sObjectIdName" dropdown
    And click on the "Done" button
    Then check visibility of the "Add a Step" button

    # add data mapper step
    When click on the "Add a Step" button
    And select "Data Mapper" integration step
    Then check visibility of data mapper ui

    When create data mapper mappings
      | user.screenName | TwitterScreenName__c |
      | text            | Description          |
      | user.name       | FirstName; LastName  |

    And scroll "top" "right"
    And click on the "Done" button

    # finish and save integration
    And click on the "Save as Draft" button
    And set integration name "Integration_import_export_test"
    And click on the "Publish" button
    # assert integration is present in list
    Then check visibility of "Integration_import_export_test" integration details

    When navigate to the "Integrations" page
    Then Integration "Integration_import_export_test" is present in integrations list
    # wait for integration to get in active state
    And wait until integration "Integration_import_export_test" gets into "Running" state

    # export the integration for import tests
    When select the "Integration_import_export_test" integration
    Then check visibility of "Integration_import_export_test" integration details
    And export the integraion

    # now we have exported integration, we can clean state and try to import
    Given clean application state
    And log into the Syndesis
    And navigate to the "Integrations" page
    And click on the "Import" button
    Then import integration "Integration_import_export_test"

    When navigate to the "Integrations" page
    Then Integration "Integration_import_export_test" is present in integrations list
    Then wait until integration "Integration_import_export_test" gets into "Stopped" state

    # check draft status after import
    When select the "Integration_import_export_test" integration
    And check visibility of "Stopped" integration status on Integration Detail page
    And sleep for jenkins delay or "3" seconds
    # start integration and wait for published state
    And start integration "Integration_import_export_test"
    And navigate to the "Integrations" page
    Then wait until integration "Integration_import_export_test" gets into "Running" state

#
#  2. integration-import with drag'n'drop
#

    When delete the "Integration_import_export_test" integration
    #wait for pod to be deleted
    And sleep for "15000" ms
    And navigate to the "Integrations" page
    And click on the "Import" button
    Then drag exported integration "Integration_import_export_test" file to drag and drop area

    When navigate to the "Integrations" page
    Then wait until integration "Integration_import_export_test" gets into "Stopped" state

    # check draft status after import
    When select the "Integration_import_export_test" integration
    And check visibility of "Stopped" integration status on Integration Detail page
    And sleep for jenkins delay or "3" seconds
    # start integration and wait for active state
    And start integration "Integration_import_export_test"
    And navigate to the "Integrations" page
    Then wait until integration "Integration_import_export_test" gets into "Running" state

#
#  2. integration-import from different syndesis instance
#
  @integration-import-from-different-instance
  Scenario: Import from different syndesis instance

    When navigate to the "Integrations" page
    And click on the "Import" button
    # import from resources TODO
    Then import integration from relative file path "src/test/resources/integrations/Imported-integration-another-instance-export.zip"

    # check that connections need credentials update TODO
    When navigate to the "Connections" page
    And check visibility of alert notification
    # update connections credentials
    And click on the "View" kebab menu button of "Imported salesforce connection"
    And check visibility of "Imported salesforce connection" connection details
    Then check visibility of alert notification

    When click on the "Edit" button
    And fill in "QE Salesforce" connection details from connection edit page
    And click on the "Validate" button
    Then check visibility of success notification

    When click on the "Save" button
    And navigate to the "Integrations" page
    #should be unpublished after import
    Then wait until integration "Imported-integration-another-instance" gets into "Stopped" state

    # check draft status after import
    When select the "Imported-integration-another-instance" integration
    Then check visibility of "Stopped" integration status on Integration Detail page

    When sleep for jenkins delay or "3" seconds
    # start integration and wait for published state:
    And start integration "Imported-integration-another-instance"
    # TODO: following steps are workaround - we have to edit and publish integration so encryption stuff
    # TODO: is taken from current syndesis instance, should be deleted changed back after fix
    And click on the "Edit Integration" button
    Then click on the "Publish" button

    When sleep for jenkins delay or "3" seconds
    And navigate to the "Integrations" page
    Then wait until integration "Imported-integration-another-instance" gets into "Running" state