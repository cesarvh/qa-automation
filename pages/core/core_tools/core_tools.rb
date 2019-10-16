require_relative '../../../spec_helper'

class CoreToolsPage

  include Logging
  include Page
  include CollectionSpacePages

  DEPLOYMENT = Deployment::CORE

  def term_lists_link; {:xpath => '//a[contains(.,"Term Lists")]'} end
  def reports_link; {:xpath => '//a[contains(.,"Reports")]'} end
  def batch_link; {:xpath => '//a[contains(.,"Batch")]'} end
  def run_button; {:name => 'run'} end
  def filter_bar; {:xpath => '//div[contains(@class, "AdminSearchBar")]//input[contains(@class,"LineInput")]'} end
  def cancel_modal_button; {:xpath => '//button[@name="cancel"]'} end
  def clear_button; {:xpath => '//button[contains(.,"Clear")]'} end
  def reports_header; {:xpath => '//div[contains(@class,"AdminTab")]//header[contains(.,"Reports")]'} end

  # Clicks the Term Lists tab in the Tools page
  def click_term_list_link
    wait_for_page_and_click term_lists_link
  end

  # Clicks the Reports tab in the Tools page
  def click_reports_link
    wait_for_page_and_click reports_link
  end

  # Clicks the Batch/Data Update tab in the Tools page
  def click_batch_link
    wait_for_page_and_click batch_link
  end

  def click_run_button
    wait_for_element_and_click run_button
  end

  def click_cancel_modal_button
    wait_for_element_and_click cancel_modal_button
  end

  def fill_filter_bar(value)
    wait_for_element_and_type(filter_bar, value)
    sleep 1
  end

  def click_clear_button
    wait_for_element_and_click clear_button
  end

end
