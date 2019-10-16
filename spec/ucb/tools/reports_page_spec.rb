require_relative '../../../spec_helper'

describe 'Reports' do

  include Logging
  include WebDriverManager

  test_run = TestConfig.new
  test_id = Time.now.to_i

  before(:all) do
    test_run.set_driver launch_browser
    @admin = test_run.get_admin_user
    @login_page = test_run.get_page CoreLoginPage
    @create_new_page = test_run.get_page CoreCreateNewPage
    @reports_page = test_run.get_page CoreReportsPage
    @search_page = test_run.get_page CoreSearchPage
    @tools_page = test_run.get_page CoreToolsPage
    @search_results_page = test_run.get_page CoreSearchResultsPage

    @test_0 = {
        CoreReportsData::REPORT_NAME.name => 'Use of Collections Approval Status Report',
        CoreReportsData::REPORT_DESC.name => 'This is a report description with some characters å√ç∂´´©',
    }

    @test_1 = {
        CoreReportsData::REPORT_NAME.name => 'Use of Collections by Requester and/or Object Report',
        CoreReportsData::REPORT_DESC.name => 'This is another report name'
    }

    @login_page.load_page
    @login_page.log_in(@admin.username, @admin.password)
    @search_page.click_tools_link
    @tools_page.click_reports_link



    # [@test_0, @test_1].each do |test|
      # test_run.set_unique_test_id(test, CoreReportsData::REPORT_NAME.name)
      # go to the tools page
      #
      # @reports_page.select_report CoreReportsData::REPORT_NAME.name
    # end
  end

  after(:all) { quit_browser test_run.driver}

  describe 'interacting with the reports page tab' do

    it 'should be able to change the name of the report and revert it' do
      @reports_page.click_report @test_0[CoreReportsData::REPORT_NAME.name]
      # @original_name = @reports_page.element_value @reports_page.report_name_locator
      @original_name = 'Use of Collections Approval Status Report'
      @temp_name = "Testing Report Name"

      @reports_page.edit_report_name @temp_name

      # expect(@object_page.element_value @object_page.date_latest_year).to eql('64')

      expect(@reports_page.element_value @reports_page.report_name_locator).to eql(@temp_name) # The name should be "ReportsTest"
      expect(@reports_page.enabled? @reports_page.revert_button).to be true
      expect(@reports_page.enabled? @reports_page.run_button).to be false

      @reports_page.revert_record
      expect(@reports_page.element_value @reports_page.report_name_locator).to eql(@original_name)
      expect(@reports_page.enabled? @reports_page.revert_button).to be false
      expect(@reports_page.enabled? @reports_page.run_button).to be true
    end

    it 'should be able to edit the name of the report' do
      @reports_page.click_report @test_0[CoreReportsData::REPORT_NAME.name]
      @original_name = 'Use of Collections Approval Status Report'
      @temp_name = "Testing Report Name"

      @reports_page.edit_report_name @temp_name

      expect(@reports_page.element_value @reports_page.report_name_locator).to eql(@temp_name) # The name should be "ReportsTest"
      expect(@reports_page.enabled? @reports_page.revert_button).to be true
      expect(@reports_page.enabled? @reports_page.run_button).to be false

      @reports_page.save_record
      expect(@reports_page.element_value @reports_page.report_name_locator).to eql(@temp_name)
      expect(@reports_page.enabled? @reports_page.revert_button).to be false
      expect(@reports_page.enabled? @reports_page.run_button).to be true

      # Change the report name back to what it used to be
      @reports_page.edit_report_name @original_name
      @reports_page.save_record
      expect(@reports_page.element_value @reports_page.report_name_locator).to eql(@original_name)
    end

    it 'should be able to change the description of the report and revert it' do
      @reports_page.click_report @test_0[CoreReportsData::REPORT_NAME.name]
      @new_description =  @test_0[CoreReportsData::REPORT_DESC.name] # Bogus
      # @prev_description = @reports_page.element_text @reports_page.report_description_locator # Actual description not working for some reason. Hard coding for now
      @prev_description = "Lists Use of Collections requests with a value in the 'Authorization' field group, filtered by authorized by, authorization status, and/or date requested range. Displays the record number, title, requested date, completed date, authorization date, authorizer and authorization status. Available output formats: PDF, CSV, MS Word."

      @reports_page.edit_description @test_0[CoreReportsData::REPORT_DESC.name]

      expect(@reports_page.element_value @reports_page.report_description_locator).to eql(@new_description) # The name should be "ReportsTest"
      expect(@reports_page.enabled? @reports_page.revert_button).to be true
      expect(@reports_page.enabled? @reports_page.run_button).to be false

      @reports_page.revert_record
      expect(@reports_page.element_value @reports_page.report_description_locator).to eql(@prev_description) # should be "Actual"
      expect(@reports_page.enabled? @reports_page.revert_button).to be false
      expect(@reports_page.enabled? @reports_page.run_button).to be true
    end

    it 'should be able to filter based on a search' do
      # @reports_page.click_search_bar
      @tools_page.fill_filter_bar("Approval")
      expect(@search_results_page.row_exists? "Use of Collections Approval Status Report").to be true
      expect(@search_results_page.row_exists? "Use of Collections by Requester and/or Object Report").to be false
    end

    it 'should show all results when the clear button is clicked' do
      @tools_page.fill_filter_bar("Approval")
      expect(@search_results_page.row_exists? "Use of Collections Approval Status Report").to be true
      expect(@search_results_page.row_exists? "Use of Collections by Requester and/or Object Report").to be false

      @tools_page.click_clear_button
      expect(@search_results_page.row_exists? "Use of Collections Approval Status Report").to be true
      expect(@search_results_page.row_exists? "Use of Collections by Requester and/or Object Report").to be true
    end

    it 'should be able to bring up a modal and dismiss it in various ways' do
        @reports_page.click_report @test_0[CoreReportsData::REPORT_NAME.name]

        # Dismiss modal using ESC
        @tools_page.click_run_button
        expect(@reports_page.exists? @reports_page.report_modal).to be true # for the modal to exist
        @reports_page.hit_escape
        expect(@reports_page.exists? @reports_page.report_modal).to be false

        #Dismiss modal using Cancel
        @tools_page.click_run_button
        expect(@reports_page.exists? @reports_page.report_modal).to be true # for the modal to exist
        @tools_page.click_cancel_modal_button
        expect(@reports_page.exists? @reports_page.report_modal).to be false

        #Dismiss modal using X
        @tools_page.click_run_button
        expect(@reports_page.exists? @reports_page.report_modal).to be true # for the modal to exist
        @reports_page.click_close_button
        expect(@reports_page.exists? @reports_page.report_modal).to be false
    end


  end
  # describe 'batch job fields' do
  #
  #   it 'should be able to change the name of the report' do
  #   end
  #
  #   it 'should be able to change the description of the report' do
  #
  #   end
  #
  #   it 'should be able to run Merge Authority Items batch job successfully' do
  #
  #   end
  # end
end

