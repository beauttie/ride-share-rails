require "test_helper"

describe DriversController do
  # Note: If any of these tests have names that conflict with either the requirements or your team's decisions, feel empowered to change the test names. For example, if a given test name says "responds with 404" but your team's decision is to respond with redirect, please change the test name.

  let (:driver) {
    Driver.create(name: "Test Driver", vin: "12345678912345678", available: true)
  }

  describe "index" do
    it "responds with success when there are many drivers saved" do
      # Arrange
      # Ensure that there is at least one Driver saved
      driver
      expect(Driver.count).must_equal 1

      # Act
      get drivers_path

      # Assert
      must_respond_with :success
    end

    it "responds with success when there are no drivers saved" do
      # Arrange
      # Ensure that there are zero drivers saved
      expect(Driver.count).must_equal 0

      # Act
      get drivers_path

      # Assert
      must_respond_with :success
    end
  end

  describe "show" do
    it "responds with success when showing an existing valid driver" do
      # Arrange
      # Ensure that there is a driver saved

      # Act
      get driver_path(driver.id)

      # Assert
      must_respond_with :success
    end

    it "responds with redirect with an invalid driver id" do
      # Arrange
      # Ensure that there is an id that points to no driver

      # Act
      get driver_path(-1)

      # Assert
      must_respond_with :redirect
      must_redirect_to drivers_path
    end
  end

  describe "new" do
    it "responds with success" do
      get new_driver_path

      must_respond_with :success
    end
  end

  describe "create" do
    it "can create a new driver with valid information accurately, and redirect" do
      # Arrange
      # Set up the form data
      driver_hash = {
          driver: {
              name: "New Driver",
              vin: "11111111111111111"
          }
      }

      # Act-Assert
      # Ensure that there is a change of 1 in Driver.count
      expect {
        post drivers_path, params: driver_hash
      }.must_change "Driver.count", 1

      # Assert
      # Find the newly created Driver, and check that all its attributes match what was given in the form data
      new_driver = Driver.find_by(name: driver_hash[:driver][:name])
      expect(new_driver.vin).must_equal driver_hash[:driver][:vin]
      expect(new_driver.available).must_equal true

      # Check that the controller redirected the user
      must_respond_with :redirect
      must_redirect_to driver_path(new_driver.id)
    end

    it "does not create a driver if the form data violates Driver validations, and responds with a redirect" do
      # Note: This will not pass until ActiveRecord Validations lesson
      # Arrange
      # Set up the form data so that it violates Driver validations
      driver_hash = {
          driver: {
              name: "",
              vin: "123"
          }
      }

      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        post drivers_path, params: driver_hash
      }.wont_change "Driver.count"

      # Assert
      # Check that the controller redirects
      must_respond_with :bad_request
    end
  end
  
  describe "edit" do
    it "responds with success when getting the edit page for an existing, valid driver" do
      # Arrange
      # Ensure there is an existing driver saved
      get edit_driver_path(driver.id)

      must_respond_with :success
    end

    it "responds with redirect when getting the edit page for a non-existing driver" do
      # Arrange
      # Ensure there is an invalid id that points to no driver
      get edit_driver_path(-1)

      must_respond_with :redirect
      must_redirect_to drivers_path
    end
  end

  describe "update" do
    it "can update an existing driver with valid information accurately, and redirect" do
      # Arrange
      # Ensure there is an existing driver saved
      driver_id = driver.id
      # Assign the existing driver's id to a local variable
      # Set up the form data
      edited_driver_hash = {
          driver: {
              name: "Test Driver 2",
              vin: "123456789ABCDEFGH"
          }
      }

      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        patch driver_path(driver_id), params: edited_driver_hash
      }.wont_change "Driver.count"

      # Assert
      # Use the local variable of an existing driver's id to find the driver again, and check that its attributes are updated
      # Check that the controller redirected the user
      edited_driver = Driver.find_by(id: driver_id)
      expect(edited_driver.name).must_equal edited_driver_hash[:driver][:name]
      expect(edited_driver.vin).must_equal edited_driver_hash[:driver][:vin]

      must_respond_with :redirect
      must_redirect_to driver_path(driver_id)
    end

    it "does not update any driver if given an invalid id, and responds with a 404" do
      # Arrange
      # Ensure there is an invalid id that points to no driver
      # Set up the form data
      edited_driver_hash = {
          driver: {
              name: "Test Driver 2",
              vin: "123456789ABCDEFGH"
          }
      }

      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        patch driver_path(-1), params: edited_driver_hash
      }.wont_change "Driver.count"

      # Assert
      # Check that the controller gave back a 404
      must_respond_with :not_found
    end

    it "does not create a driver if the form data violates Driver validations, and responds with a redirect" do
      # Note: This will not pass until ActiveRecord Validations lesson
      # Arrange
      # Ensure there is an existing driver saved
      # Assign the existing driver's id to a local variable
      driver_id = driver.id

      # Set up the form data so that it violates Driver validations
      edited_driver_hash = {
          driver: {
              name: "",
              vin: "123"
          }
      }

      # Act-Assert
      # Ensure that there is no change in Driver.count
      expect {
        patch driver_path(driver_id), params: edited_driver_hash
      }.wont_change "Driver.count"

      # Assert
      # Check that the controller redirects
      must_respond_with :bad_request
    end
  end

  describe "destroy" do
    it "destroys the driver instance in db when driver exists and has no trips, then redirects" do
      driver_id = driver.id

      expect {
        delete driver_path(driver_id)
      }.must_change 'Driver.count', -1

      deleted_driver = Driver.find_by(id: driver_id)

      expect(deleted_driver).must_be_nil

      must_respond_with :redirect
      must_redirect_to drivers_path
    end

    it "does not change the db when driver exists and has trips, must respond with bad request" do
      driver_id = driver.id
      passenger = Passenger.create(name: "Test Passenger", phone_num: "206-555-5555")
      Trip.create(date: "2020-11-05",
                  rating: nil,
                  cost: 1000,
                  passenger_id: passenger.id,
                  driver_id: driver_id)

      expect {
        delete driver_path(driver_id)
      }.wont_change 'Driver.count'

      driver_with_trips = Driver.find_by(id: driver_id)

      expect(driver_with_trips).must_equal driver

      must_respond_with :redirect
      must_redirect_to driver_path(driver_id)
    end

    it "does not change the db when the driver does not exist, then responds with not found" do
      expect {
        delete driver_path(-1)
      }.wont_change 'Driver.count'

      must_respond_with :not_found
    end
  end
end
