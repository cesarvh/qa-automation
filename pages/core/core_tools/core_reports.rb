require_relative '../../../spec_helper'

class CoreReportsPage

  include Page
  include Logging
  include CollectionSpacePages

  DEPLOYMENT = Deployment::CORE

  # Select report
  def report_description_locator; text_area_locator([], CoreReportsData::REPORT_DESC.name) end
  def report_name_locator; input_locator([], CoreReportsData::REPORT_NAME.name) end
  def report_modal; {:xpath => '//div[@class="cspace-ui-InvocationModal--common"]'} end

  # {:xpath => '//div[contains(@class,"ConfirmRecordDeleteModal")]//header/following-sibling::div/span'} end

  def select_report(report_name)
    {:xpath => "//div[@class=\"cspace-ui-SearchResultTable--common\"]//*[@aria-label=\"row\"][contains(.,\"#{report_name}\")]"}
  end

  # Clicks a search results row containing a given string
  # @param [String] unique_identifier
  def click_report(unique_identifier)
    wait_for_page_and_click select_report(unique_identifier)
  end


  # Edit the name of the report
  def edit_report_name(new_name)
    logger.debug("Changing name to '#{new_name}'")
    wait_for_element_and_type(report_name_locator, new_name) if new_name
  end

  # Edit the description
  def edit_description(description)
    logger.debug("Changing the description to '#{description}'")
    wait_for_element_and_type(report_description_locator, description) if description
  end
  
  # click run and cancel report
  def run_and_cancel_report(data_set)
    # report_name = get report name from the dataset
    # go_to_report report_name
    # click the run button
    # click the X
    # make sure modal is dismissed
    # click the run button
    # click cancel button
    # make sure the modal is dismissed
    # click the run button
    # press the escape key
    # make sure the modal is dismissed
  end

  #run a report
  def fill_parameters(data_set)

  end


  # Filter by name
end