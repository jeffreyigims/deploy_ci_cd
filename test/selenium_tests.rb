require "selenium-webdriver"
require 'test_helper'

class SeleniumTests < ActiveSupport::TestCase

    setup do 
        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument('--headless')
        @@driver = Selenium::WebDriver.for :chrome, options: options 
    end 

    test "test creating a book" do 
        # navigate to the specific page we want 
        @@driver.get "http://localhost:3000/books/new"

        # set a timeout to wait for the elements to appear on our page 
        wait = Selenium::WebDriver::Wait.new(:timeout => 10)
        wait.until { @@driver.find_element(:id => "book_title") }

        # fill out the form to create a book by sending input from the driver 
        @@driver.find_element(:id, 'book_title').send_keys 'A Storm of Swords'
        @@driver.find_element(:id, 'book_publisher_id').send_keys '1'

        # some date data 
        day = Date.current.day 
        month = Date.current.month
        @@driver.find_element(:id, 'book_proposal_date_1i').send_keys (Date.current - 3.years)
        @@driver.find_element(:id, 'book_proposal_date_2i').send_keys month
        @@driver.find_element(:id, 'book_proposal_date_3i').send_keys day

        @@driver.find_element(:id, 'book_contract_date_1i').send_keys (Date.current - 2.years)
        @@driver.find_element(:id, 'book_contract_date_2i').send_keys month
        @@driver.find_element(:id, 'book_contract_date_3i').send_keys day

        @@driver.find_element(:id, 'book_published_date_1i').send_keys (Date.current - 1.year)
        @@driver.find_element(:id, 'book_published_date_2i').send_keys month
        @@driver.find_element(:id, 'book_published_date_3i').send_keys day

        @@driver.find_element(:id, 'book_units_sold').send_keys '4000'

        # submit form, we should then be redirected to the page for the book we just created 
        @@driver.find_element(:name, 'commit').click

        # assert that all of the information we just enterred is displayed somewhere on the page
        assert @@driver.find_element(:tag_name, "body").text.include?("A Storm of Swords"), "Title should be present"
        assert @@driver.find_element(:tag_name, "body").text.include?("Bantam Spectra"), "Publisher should be present"
        assert @@driver.find_element(:tag_name, "body").text.include?((Date.current - 1.year).to_s), "Published date should be present"
        assert @@driver.find_element(:tag_name, "body").text.include?((Date.current - 2.year).to_s), "Contract date should be present"
        assert @@driver.find_element(:tag_name, "body").text.include?((Date.current - 3.year).to_s), "Proposal date should be present"
        assert @@driver.find_element(:tag_name, "body").text.include?("4000"), "Units sold should be present"
    end 

    test "test creating a publisher" do 
        # navigate to the specific page we want 
        @@driver.get "http://localhost:3000/publishers/new"

        # set a timeout to wait for the elements to appear on our page 
        wait = Selenium::WebDriver::Wait.new(:timeout => 10)
        wait.until { @@driver.find_element(:id => "publisher_name") }

        # fill out the form to create a publisher by sending input from the driver 
        @@driver.find_element(:id, 'publisher_name').send_keys 'Macmillan'

        # submit form, we should then be redirected to the page for the publisher we just created 
        @@driver.find_element(:name, 'commit').click

        # assert that all of the information we just enterred is displayed somewhere on the page
        assert @@driver.find_element(:tag_name, "body").text.include?("Macmillan"), "Publisher name should be present"
    end 

    test "test creating an author" do 
        # navigate to the specific page we want 
        @@driver.get "http://localhost:3000/authors/new"

        # set a timeout to wait for the elements to appear on our page 
        wait = Selenium::WebDriver::Wait.new(:timeout => 10)
        wait.until { @@driver.find_element(:id => "author_first_name") }

        # fill out the form to create an author by sending input from the driver 
        @@driver.find_element(:id, 'author_first_name').send_keys 'J.K.'
        @@driver.find_element(:id, 'author_last_name').send_keys 'Rowling'

        # submit form, we should then be redirected to the page for the author we just created 
        @@driver.find_element(:name, 'commit').click

        # assert that all of the information we just enterred is displayed somewhere on the page
        assert @@driver.find_element(:tag_name, "body").text.include?("J.K."), "Author first name should be present"
        assert @@driver.find_element(:tag_name, "body").text.include?("Rowling"), "Author last name should be present"

    end 
end
