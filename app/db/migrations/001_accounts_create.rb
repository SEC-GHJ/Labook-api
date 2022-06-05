# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      uuid :account_id, primary_key: true

      String :account, null: false, unique: true
      Float :gpa, null: false, unique: false
      String :ori_school, null: false, unique: false
      String :ori_department, null: false, unique: false
      String :password_digest, null: false
      String :email, null: false, unique: true
      String :line_access_token_secure, null: true
      Integer :show_all, null: false
      Integer :accept_mail, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
