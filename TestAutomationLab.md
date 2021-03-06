## Part 1: Setup 

1. Create a [Heroku](https://www.heroku.com) account if you don't have one already. 

2. Install the [Heroku](https://devcenter.heroku.com/articles/heroku-cli) and [Travis](https://github.com/travis-ci/travis.rb#readme) command line clients. 

3. Login to both clients with `heroku login` and `travis login --com`. Note we must use `--com` in every travis command.

4. Make sure you have access to the BookManager repository we created for the BookManager Docker lab.

## Part 2: Travis Introduction 

[Travis CI](https://www.travis-ci.com) is a tool that supports configuring applications to support continous integration. The core of the tool is to help us automate our builds, testing, and deployments. 

1. Let's link our repository to travis. Go to [travis](https://travis-ci.com/) and [sign up with GitHub](https://travis-ci.com/signin). Accept the Authorization of Travis CI. You’ll be redirected to GitHub. Click on your profile picture in the top right of your Travis Dashboard, click Settings and then the green Activate button, and select the BookManager repo so we can use it with Travis CI.

1. Our first rule of development is to never work off of the main branch. Check out a different branch for us to work on called `staging`. 

2. Let's add the tool to our app. Go to the gemfile and add `gem 'travis'` before running `bundle install` 

3. Navigate to the root of our project directory and create a `.travis.yml` file or run `travis init` from the command line to create it automatically. This file will contain all of the configurations necessary for the tool to run.

4. In the file, paste in the following contents: 

	```
	language: ruby
	rvm: 2.5.7
	services:
	  - postgresql
	before_script:
	  - bundle exec rails db:create
	  - bundle exec rails db:migrate
	script: 
	  - "bundle exec rails test test/controllers/authors_controller_test"
	```
	Note we are specifying a Ruby version for Travis to use during the build. The script argument specifies what commands Travis will execute when we push our changes to GitHub. We want Travis to execute our test suite when we push code changes.
	
5. Let's push our changes to GitHub with the `.travis.yml` file now added. We can see the status of our build on GitHub and on Travis. On GitHub, navigate to our branch and click on the status symbol next to the unique commit identifier and then click details to view our Travis checks. We can also see the status from the [Travis](https://travis-ci.com) dashboard. Verify that the build successfully completes.

6. We have configured travis to run our test suite when we push code changes. We can also configure travis to run when we make pull requests. Navigate back to the `.travis.yml` file and add in the following contents: 

   ```
	branches:
	  if: type = pull_request
	  only: 
	    - main
	```
	Note we are specifying Travis to build our app on pull requests into the main branch only.
	
10. Push the changes to GitHub, and open a pull request from our staging branch into main. You should see the Travis build start to run on the pull request page. When the apps builds successfully, Travis will notify you that the changes pass inspectionn can be merged into main. Merge the pull request.

6. Now we have incorporated testing into our continous integration strategy but what about deployment? We can configure Travis to deploy our application on a successful build. Travis supports a plethora of deployment engines; We will use Heroku for our purposes. 

7. We need to set up an app on Heroku to deploy to. Go to [Heroku](www.heroku.com) and create a new app. Give the app any valid name. Select GitHub as our deployment method and then link our repository to the new app by searching for it. Enable automatic deploys from the main branch and select the option to wait for continuous integration to pass before deploying.

8. Go back to the command line at the root of our repository and run `heroku git:remote -a NAME_OF_APP_PLACEHOLDER` to create a remote reference to our repo. We can now deploy directly to our Heroku app if we want, but we will configure automatic deployments.

9. Navigate back to your `.travis.yml` file and paste in the following contents:
	
	```
	deploy:
	  provider: heroku
	  api_key: 
	    secure: API_KEY_PLACEHOLDER
	  app: NAME_OF_APP_PLACEHOLDER
	  on: main
	  run:
	    - "rails db:migrate"
	    - "rails db:seed"
	```
	Note that we are also specifying for Heroku to migrate and seed our database when the app is deployed.
	

7. Run `travis encrypt $(heroku auth:token) --add deploy.api_key --com` from the command line to fetch your encrypted Heroku API key and put it in our placeholder.

8. Push our changes to GitHub. Verify that our build passes on [Travis](https://travis-ci.org), and then navigate to Heroku to see our app being deployed. If the app deploys successfully, visit our deployed web application!

## Part 3: Selenium Introduction

In the previous part of the lab, we were able to achieve apply testing and deployment to our continous integration strategy rather easily with Travis. Our current testing strategy involves a suite of unit tests to ensure our models and controllers work correctly. In this part of the lab we will see why this is not sufficient to ensure our app will function correctly and how we can use Selenium to create integration and end-to-end testing of our app as well. 

1. Right now, we have Travis configured to run our unit test suite before deploying to ensure we are pushing quality code to production. So if our build passes, we know our app will work as epected right? Go to our deployed app on Heroku and go to the books page. 

2. Observe how the column for publishers does not display the name of the publisher but the unique identifier. This is not what we want but our unit tests did not catch this. 

3. Selenium is a tool that allows us to test our application from end-to-end to ensure our appliction is functioning the way we expect it to. The tool includes a web driver so we can simulate our tests like how a user would interact with our app.

4. Add `gem 'selenium-webdriver'` to your gem file, and run `bundle install`.

5. Create a file called `selenium_tests.rb` in the test directory of your app and paste in the following contents: 

```
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
	
end 	
```
	
6. Read through the contents of the file to understand what is going on. We are creating an instance of a web driver and then simulating the process of how a user would create a new book. We then check that the user is redirected to the page for the newly created book and that the page displays the correct information. 

7. Configure Travis to run our new tests by adjusting the scripts section. Push our changes to GitHub and create a pull request. Check GitHub or the Travis dashboard for the repository and ensure the build failed. 

8. Go back to the repository and fix the view so that the assertion will now pass. You can also run the tests locally by running `rails test test/selenium_tests`. Push the changes to GitHub and create a pull request, ensure the tests run successfully and then merge the changes, and visit the app on Heroku to ensure our code changes took effect.

7. Create two new tests similar to the test given that will test the process of a user creating a new author and a new publisher and assert all of the information is displayed correctly on the author and publisher pages after creating the new entities. 

8. Push the changes to GitHub, create and merge the changes into main, and visit the deployed app on Heroku!

















