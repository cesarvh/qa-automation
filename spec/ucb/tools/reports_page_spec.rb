require_relative '../../../spec_helper'

describe 'Reports' do

  include Logging
  include WebDriverManager

  test_run = TestConfig.new Deployment::CORE
  test_id = Time.now.to_i

  before(:all) do
    test_run.set_driver launch_browser
    @admin = test_run.get_admin_user
    @login_page = test_run.get_page CoreLoginPage
    @create_new_page = test_run.get_page CoreCreateNewPage
    @reports_page = test_run.get_page CoreInvocablesPage
    @search_page = test_run.get_page CoreSearchPage
    @tools_page = test_run.get_page CoreToolsPage
    @search_results_page = test_run.get_page CoreSearchResultsPage
    @admin_page = test_run.get_page CoreAdministrationPage

    @test_0 = {
        CoreInvocablesData::INVOCABLE_NAME.name => 'Use of Collections Approval Status Report',
        CoreInvocablesData::INVOCABLE_DESC.name =>  'Lists Use of Collections requests with a value in the \'Authorization\' field group, filtered by authorized by, authorization status, and/or date requested range. Displays the record number, title, requested date, completed date, authorization date, authorizer and authorization status. Available output formats: PDF, CSV, MS Word.',
    }

    @test_1 = {
        CoreInvocablesData::INVOCABLE_NAME.name => 'Use of Collections by Requester and/or Object Report',
        CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label => 'Runs on',
        CoreInvocablesData::INVOCABLE_REPORT_LIST_PANEL.label => 'Reports'
    }

    @login_page.load_page

    # login as admin to create new account
    @login_page.log_in(@admin.username, @admin.password)
    @admin_page.load_page
    @admin_page.create_user("test@report.com", "Editor and Invoker", "EditorAndInvoker", "Report Editor and Invoker")
    @login_page.log_out

    @login_page.log_in("test@report.com", "Editor and Invoker")
    # check if the user exists
    # if not, create the user
  end

  after(:all) { quit_browser test_run.driver}

  # Done done
  describe 'general report UI interactions' do
    @login_page.log_in(@admin.username, @admin.password)
    @search_page.click_tools_link
    @tools_page.click_reports_link

    it 'should be able to filter based on a search' do
      @tools_page.fill_filter_bar(@test_0[CoreInvocablesData::INVOCABLE_NAME.name])
      expect(@search_results_page.row_exists? @test_0[CoreInvocablesData::INVOCABLE_NAME.name]).to be true
      expect(@search_results_page.row_exists? @test_1[CoreInvocablesData::INVOCABLE_NAME.name]).to be false
    end

    it 'should show all results when the clear button is clicked' do
      @tools_page.fill_filter_bar(@test_0[CoreInvocablesData::INVOCABLE_NAME.name])
      expect(@search_results_page.row_exists? @test_0[CoreInvocablesData::INVOCABLE_NAME.name]).to be true
      expect(@search_results_page.row_exists? @test_1[CoreInvocablesData::INVOCABLE_NAME.name]).to be false

      @tools_page.click_clear_button
      expect(@search_results_page.row_exists? @test_0[CoreInvocablesData::INVOCABLE_NAME.name]).to be true
      expect(@search_results_page.row_exists? @test_1[CoreInvocablesData::INVOCABLE_NAME.name]).to be true
    end

    it 'should be able to bring up a modal and dismiss it using the escape key' do
      @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]

      @tools_page.click_run_button
      expect(@reports_page.exists? @reports_page.invocable_modal).to be true # for the modal to exist
      @reports_page.hit_escape
      expect(@reports_page.exists? @reports_page.invocable_modal).to be false
    end

    it 'should be able to bring up a modal and dismiss it using the cancel button' do
      @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]

      @tools_page.click_run_button
      expect(@reports_page.exists? @reports_page.invocable_modal).to be true # for the modal to exist
      @tools_page.click_cancel_modal_button
      expect(@reports_page.exists? @reports_page.invocable_modal).to be false
    end

    it 'should be able to bring up a modal and dismiss it using the close button' do
      @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]

      @tools_page.click_run_button
      expect(@reports_page.exists? @reports_page.invocable_modal).to be true # for the modal to exist
      @reports_page.click_close_button
      expect(@reports_page.exists? @reports_page.invocable_modal).to be false
    end


    it 'should be able to collapse and uncollapse the Reports and Runs on panels' do
      @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]

      #runs on
      # uncollapse it
      @reports_page.uncollapse_panel_if_collapsed CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label
      expect(@reports_page.is_collapsed CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label).to be false

      # collapse it
      @reports_page.toggle_panel CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label
      expect(@reports_page.is_collapsed CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label).to be true


      # uncollapse it
      @reports_page.toggle_panel CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label
      expect(@reports_page.is_collapsed CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label).to be false


      #Reports
      @reports_page.uncollapse_panel_if_collapsed CoreInvocablesData::INVOCABLE_REPORT_LIST_PANEL.label
      expect(@reports_page.is_collapsed CoreInvocablesData::INVOCABLE_REPORT_LIST_PANEL.label).to be false

      # collapse it
      @reports_page.toggle_panel CoreInvocablesData::INVOCABLE_REPORT_LIST_PANEL.label
      expect(@reports_page.is_collapsed CoreInvocablesData::INVOCABLE_REPORT_LIST_PANEL.label).to be true


      # recollapse it
      @reports_page.toggle_panel CoreInvocablesData::INVOCABLE_REPORT_LIST_PANEL.label
      expect(@reports_page.is_collapsed CoreInvocablesData::INVOCABLE_REPORT_LIST_PANEL.label).to be false

    end
  end


  describe 'interacting with the reports page tab as a user with EDIT AND INVOKE permissions' do
    # FIX ME: Change user role
    @admin_page.load_page
    @admin_page.change_user_role(@test_0[CoreInvocablesData::REPORTER_AND_EDITOR_ROLE.name]) # // FIX ME
    @tools_page.load_page

    @search_page.click_tools_link
    @tools_page.click_reports_link

    context 'checking ability to edit fields' do
      it 'should be able to change the name of a report' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        sleep 1
        expect(@reports_page.element_value @reports_page.invocable_name_locator).to eql(@test_0[CoreInvocablesData::INVOCABLE_NAME.name])
        expect(@reports_page.enabled? @reports_page.invocable_name_locator).to be true
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true

        @reports_page.edit_invocable_name_and_save("This is a new test description")
        expect(@reports_page.element_value @reports_page.invocable_description_locator).not_to equal(@test_0[CoreInvocablesData::INVOCABLE_DESC.name])

        @reports_page.edit_invocable_name_and_save(@test_0[CoreInvocablesData::INVOCABLE_DESC.name])
        expect(@reports_page.element_value @reports_page.invocable_description_locator).to equal(@test_0[CoreInvocablesData::INVOCABLE_DESC.name])

      end

      it 'should be able to change the description of a report' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        sleep 1
        expect(@reports_page.element_value @reports_page.invocable_description_locator).to eql(@test_0[CoreInvocablesData::INVOCABLE_DESC.name ])
        expect(@reports_page.enabled? @reports_page.invocable_description_locator).to be true
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true

        @reports_page.edit_description_and_save("This is a new test description for the user who can edit ")
        expect(@reports_page.element_value @reports_page.invocable_description_locator).not_to equal(@test_0[CoreInvocablesData::INVOCABLE_DESC.name])

        @reports_page.edit_description_and_save(@test_0[CoreInvocablesData::INVOCABLE_DESC.name])
        expect(@reports_page.element_value @reports_page.invocable_description_locator).to equal(@test_0[CoreInvocablesData::INVOCABLE_DESC.name])
      end

      # Done
      it 'should not be able to alter the Jasper file associated with the report' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        @reports_page.uncollapse_panel_if_collapsed CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label

        expect(@reports_page.enabled? @reports_page.invocable_report_filename_locator).to be false
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true
      end

      # Done
      it 'should not be able to alter the report contexts' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        @reports_page.uncollapse_panel_if_collapsed CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label
        expect(@reports_page.enabled? @reports_page.invocable_no_ctx_locator).to be false
        expect(@reports_page.enabled? @reports_page.invocable_single_ctx_locator).to be false
        expect(@reports_page.enabled? @reports_page.invocable_group_ctx_locator).to be false
        expect(@reports_page.enabled? @reports_page.invocable_list_ctx_locator).to be false
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true
      end

      # Done
      it 'should not be able to alter the record types or default MIME type' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        @reports_page.uncollapse_panel_if_collapsed CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label
        expect(@reports_page.enabled? @reports_page.invocable_report_doctypes_locator).to be false
        expect(@reports_page.enabled? @reports_page.invocable_mimetype_locator).to be false
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true
      end
    end

    # DONE
    context 'checking ability to invoke' do
      it 'should show and be able to click the run button' do
        expect(@reports_page.exists? @reports_page.run_button).to be true
        expect(@reports_page.enabled? @reports_page.run_button).to be true

        @reports_page.click_element @reports_page.run_button
        expect(@reports_page.exists? @reports_page.invocable_modal).to be true

        # TO DO: Add functionality to be able to run a report and retrieve the response code (ie. 200 vs 401)
      end
    end
  end

  # DONE (FIX USER)
  describe 'interacting with the reports page tab as a user with ONLY INVOKE permissions' do
    # Change user role
    @admin_page.load_page
    @admin_page.change_user_role(@test_0[CoreInvocablesData::REPORT_INVOKER_ROLE.name]) # // FIX ME
    @tools_page.load_page

    @search_page.click_tools_link
    @tools_page.click_reports_link


    # Done
    context 'checking inability to edit fields' do
      it 'should not be able to change the name of a report' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        sleep 1
        expect(@reports_page.element_value @reports_page.invocable_name_locator).to eql(@test_0[CoreInvocablesData::INVOCABLE_NAME.name])
        expect(@reports_page.enabled? @reports_page.invocable_name_locator).to be false
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true
      end

      it 'should not be able to change the description of a report' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        sleep 1
        expect(@reports_page.element_value @reports_page.invocable_description_locator).to eql(@test_0[CoreInvocablesData::INVOCABLE_DESC.name ])
        expect(@reports_page.enabled? @reports_page.invocable_description_locator).to be false
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true
      end

      # Done
      it 'should not be able to alter the Jasper file associated with the report' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        @reports_page.uncollapse_panel_if_collapsed CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label

        expect(@reports_page.enabled? @reports_page.invocable_report_filename_locator).to be false
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true
      end

      # Done
      it 'should not be able to alter the report contexts' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        @reports_page.uncollapse_panel_if_collapsed CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label
        expect(@reports_page.enabled? @reports_page.invocable_no_ctx_locator).to be false
        expect(@reports_page.enabled? @reports_page.invocable_single_ctx_locator).to be false
        expect(@reports_page.enabled? @reports_page.invocable_group_ctx_locator).to be false
        expect(@reports_page.enabled? @reports_page.invocable_list_ctx_locator).to be false
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true
      end

      # Done
      it 'should not be able to alter the record types or default MIME type' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        @reports_page.uncollapse_panel_if_collapsed CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label
        expect(@reports_page.enabled? @reports_page.invocable_report_doctypes_locator).to be false
        expect(@reports_page.enabled? @reports_page.invocable_mimetype_locator).to be false
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true
      end
    end

    # Done
    context 'checking ability to invoke' do
      it 'should show and be able to click the run button' do
        expect(@reports_page.exists? @reports_page.run_button).to be true
        expect(@reports_page.enabled? @reports_page.run_button).to be true

        @reports_page.click_element @reports_page.run_button
        expect(@reports_page.exists? @reports_page.invocable_modal).to be true
        expect(@reports_page.enabled? @reports_page.run_button).to be true

        # TO DO: Add functionality to be able to run a report and retrieve the response code (ie. 200 vs 401)
      end
    end
  end

  # DONE
  describe 'interacting with the reports page tab as a user with ONLY EDIT permissions' do
    @admin_page.load_page
    @admin_page.change_user_role(@test_0[CoreInvocablesData::REPORT_EDITOR_ROLE.name]) # // FIX ME
    @tools_page.load_page

    @search_page.click_tools_link
    @tools_page.click_reports_link

    context 'checking ability to edit only the name and desc of the report' do
      it 'should be able to change the name of a report' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        sleep 1
        expect(@reports_page.element_value @reports_page.invocable_name_locator).to eql(@test_0[CoreInvocablesData::INVOCABLE_NAME.name])
        expect(@reports_page.enabled? @reports_page.invocable_name_locator).to be true
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true

        @reports_page.edit_invocable_name_and_save("This is a new test description")
        expect(@reports_page.element_value @reports_page.invocable_description_locator).not_to equal(@test_0[CoreInvocablesData::INVOCABLE_DESC.name])

        @reports_page.edit_invocable_name_and_save(@test_0[CoreInvocablesData::INVOCABLE_DESC.name])
        expect(@reports_page.element_value @reports_page.invocable_description_locator).to equal(@test_0[CoreInvocablesData::INVOCABLE_DESC.name])

      end

      it 'should be able to change the description of a report' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        sleep 1
        expect(@reports_page.element_value @reports_page.invocable_description_locator).to eql(@test_0[CoreInvocablesData::INVOCABLE_DESC.name ])
        expect(@reports_page.enabled? @reports_page.invocable_description_locator).to be true
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true

        @reports_page.edit_description_and_save("This is a new test description for the user who can edit ")
        expect(@reports_page.element_value @reports_page.invocable_description_locator).not_to equal(@test_0[CoreInvocablesData::INVOCABLE_DESC.name])

        @reports_page.edit_description_and_save(@test_0[CoreInvocablesData::INVOCABLE_DESC.name])
        expect(@reports_page.element_value @reports_page.invocable_description_locator).to equal(@test_0[CoreInvocablesData::INVOCABLE_DESC.name])
      end

      # Done
      it 'should not be able to alter the Jasper file associated with the report' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        @reports_page.uncollapse_panel_if_collapsed CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label

        expect(@reports_page.enabled? @reports_page.invocable_report_filename_locator).to be false
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true
      end

      # Done
      it 'should not be able to alter the report contexts' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        @reports_page.uncollapse_panel_if_collapsed CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label
        expect(@reports_page.enabled? @reports_page.invocable_no_ctx_locator).to be false
        expect(@reports_page.enabled? @reports_page.invocable_single_ctx_locator).to be false
        expect(@reports_page.enabled? @reports_page.invocable_group_ctx_locator).to be false
        expect(@reports_page.enabled? @reports_page.invocable_list_ctx_locator).to be false
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true
      end

      # Done
      it 'should not be able to alter the record types or default MIME type' do
        @reports_page.click_invocable @test_0[CoreInvocablesData::INVOCABLE_NAME.name]
        @reports_page.uncollapse_panel_if_collapsed CoreInvocablesData::INVOCABLE_RUNS_ON_PANEL.label
        expect(@reports_page.enabled? @reports_page.invocable_report_doctypes_locator).to be false
        expect(@reports_page.enabled? @reports_page.invocable_mimetype_locator).to be false
        expect(@reports_page.enabled? @reports_page.revert_button).to be false
        expect(@reports_page.enabled? @reports_page.run_button).to be true
      end
    end

    # Done
    context 'checking inability to invoke' do
      it 'should not show the run button' do
        expect(@reports_page.exists? @reports_page.run_button).to be false
      end
    end
  end

  # DONE
  describe 'interacting with the reports page as a user without edit or invoke permissions' do
    # change user permission to "No Invocable Permissions"
    @admin_page.load_page
    @admin_page.change_user_role(@test_0[CoreInvocablesData::NO_REPORT_PERMISSIONS_ROLE.name]) # // FIX ME
    @tools_page.load_page

    @search_page.click_tools_link

    it 'should not be able to see the reports tab within the Tools menu' do
      expect(@tools_page.exists? @tools_page.reports_link).to be false
    end
  end
end

