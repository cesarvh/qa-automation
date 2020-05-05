require_relative '../../spec_helper'

class CoreAdministrationPage

  include Logging
  include Page
  include CollectionSpacePages
  include CoreSearchResultsPage

  DEPLOYMENT = Deployment::CORE

  def admin_users_link; {:xpath => '//a[contains(.,"Users")]'} end
  def admin_roles_link; {:xpath => '//a[contains(.,"Roles and Permissions")]'} end
  def email_field_locator; {:xpath => '//input[@data-name="email"]'} end
  def username_field_locator; {:xpath => '//input[@data-name="screenName"]'} end
  def password_field_locator; {:xpath => '//input[@data-name="password"]'} end
  def confirm_password_field_locator; {:xpath => '//input[@data-name="confirmPassword"]'} end
  def role_locator(role); {:xpath => "//fieldset[@data-name=\"roleList\"]//li[contains(.,\"#{role}\")]//span"} end

  # User object should contain {email, full name, password, role}
  def create_new_user(email, name, password, role)
    click_element admin_users_link
    click_element create_new_button

    wait_for_element_and_type(email_field_locator, email)
    wait_for_element_and_type(username_field_locator, name)
    wait_for_element_and_type(password_field_locator, password)
    wait_for_element_and_type(confirm_password_field_locator, password)
    wait_for_element_and_click role_locator(role)

    save_record
  end

  # Change user user to role role
  def change_user_role(user, role_name)
    click_element admin_users_link

    fill_search_filter_bar user
    click_result user
    wait_for_element_and_click(role_locator(role_name))

    save_record
  end

  # def create_user_role(role_name, permissions)
  # TO DO: For now assume that this already exists
  # end
end
