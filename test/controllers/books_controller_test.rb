require 'test_helper'

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:one)
    puts @book.publisher_id
  end

  test "should get index" do
    get books_url
    assert_response :success
  end

  test "should get new" do
    get new_book_url
    assert_response :success
  end

  test "should create book" do
    assert_difference('Book.count') do
      post books_url, params: { book: { contract_date: @book.contract_date, proposal_date: @book.proposal_date, published_date: @book.published_date, publisher_id: @book.publisher_id, title: @book.title, units_sold: @book.units_sold } }
    end

    assert_redirected_to book_url(Book.last)
  end

  test "should show book" do
    get book_url(@book)
    assert_response :success
  end

  test "should get edit" do
    get edit_book_url(@book)
    assert_response :success
  end

  test "should update book" do
    patch book_url(@book), params: { book: { contract_date: @book.contract_date, proposal_date: @book.proposal_date, published_date: @book.published_date, publisher_id: @book.publisher_id, title: @book.title, units_sold: @book.units_sold } }
    assert_redirected_to book_url(@book)
  end

  test "should destroy book" do
    assert_difference('Book.count', -1) do
      delete book_url(@book)
    end

    assert_redirected_to books_url
  end
end
