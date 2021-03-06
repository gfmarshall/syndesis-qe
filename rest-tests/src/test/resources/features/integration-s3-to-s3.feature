# @sustainer: tplevko@redhat.com

Feature: Integration - S3 to S3

  @integrations-s3-s3
  Scenario: Create
    Given clean application state
    And create sample buckets on S3 with name "syndesis-server-bucket-out"
    And create sample buckets on S3 with name "syndesis-server-bucket-in"
    And create S3 connection using "syndesis-server-bucket-out" bucket
    And create S3 connection using "syndesis-server-bucket-in" bucket
    And create S3 polling START action step with bucket: "syndesis-server-bucket-out"
    And create S3 copy FINISH action step with bucket: "syndesis-server-bucket-in"
    When create integration with name: "S3 to S3 rest test"
    Then wait for integration with name: "S3 to S3 rest test" to become active
    Then create a new text file in bucket "syndesis-server-bucket-out" with name "test.txt" and text "Hello world!"
    Then validate bucket with name "syndesis-server-bucket-in" contains file with name "test.txt" and text "Hello world!"
    Then clean S3 to S3 scenario, remove two sample buckets with names: "syndesis-server-bucket-in, syndesis-server-bucket-out"
