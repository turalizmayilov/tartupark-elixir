Feature: Parking allocation
  As an automated system (STRS)
  Such that parking spaces can be allocated  in an optimal way
  I want to get the information about the parking space that are closer to the destination address
        and book the available parking space
  Scenario Outline: Parking via mobile phone
    Given the following parking spaces
          | street      | type |
          | Vanemuise   | Zone A |
          | Vaksali     | Zone B |
          | Umera       | Parking time of 60 |
          | Pargi       | Parking time of 120 |
    When I enter my destination of "<destinations>"
    And I want to park my car in "<street choice>"
    And I want my parking time start in "<start_time_choice>" and last until "<end_time_choice>"
    And I enter the parking information on the STRS Customer app
    When I summit the parking request
    Then I should be notified "<notification>"

    Examples:
        | destinations     | real_time_configured    | street_choice  | payment_choice  | start_time_choice | end_time_choice | notification |
        | Tamme puiestee 1 | yes (balance 12.5 euro) | Vanemuise      | hourly          | 15:00             | 15:20           | parking space for 20 mins is booked and your fee is 2 euros |
        | Tamme puiestee 1 | no                      | Vanemuise      | hourly          | 17:00             | 20:00           | parking space for 180 mins is booked and your fee is 2 euros |
        | Tamme puiestee 1 | no                      | Vanemuise      | hourly          | 21:00             | 23:00           | parking space for 120 mins is booked and there is no fee |
        | Tamme puiestee 1 | yes (balance 12.5 euro) | Vaksali        | real time       | 15:00             | 17 minutes      | parking space with real time is booked and your fee will be sent at the end of month (fee shown at the end of month: 12.82) |
        | Tamme puiestee 1 | yes (balance 12.5 euro) | Vaksali        | real time       | 17:43             | 180 minutes     | parking space with real time is booked and your fee will be sent at the end of month (fee shown at the end of month: 13.12) |
        | Tamme puiestee 1 | no                      | Vaksali        | real time       | 21:00             | 60 minutes      | parking space with real time is booked and there is no fee (fee shown when left: 0) |
        | Tamme puiestee 1 | no                      | Umera          | no payment      | 15:00             | 16:00           | parking space with max parking time of 60 mins is booked |
        | Tamme puiestee 1 | no                      | Umera          | no payment      | 15:00             | 19:00           | parking time can not exceed 60 mins |
        | Tamme puiestee 1 | no                      | Pargi          | no payment      | 15:00             | 17:00           | parking space with max parking time of 120 mins is booked |
        | Tamme puiestee 1 | no                      | Pargi          | no payment      | 15:00             | 19:00           | parking time can not exceed 120 mins |
