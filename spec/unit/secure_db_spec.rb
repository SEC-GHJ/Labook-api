# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test SecureDB class' do
  it 'Security: should encrypt text' do
    test_data = 'test data'
    test_sec = SecureDB.encrypt(test_data)
    _(test_sec).wont_equal test_data
  end

  it 'Security: should decrypt ASCII' do
    test_data = 'test data ~ 1& \n'
    test_sec = SecureDB.encrypt(test_data)
    test_decrypted = SecureDB.decrypt(test_sec)
    _(test_data).must_equal test_decrypted
  end

  it 'Security: should decrypt NON-ASCII' do
    test_data = '好吃的麵包就是好吃'
    test_sec = SecureDB.encrypt(test_data)
    test_decrypted = SecureDB.decrypt(test_sec)
    _(test_data).must_equal test_decrypted
  end
end
