require_relative '../../config/environment'
require_all 'lib'

class Dog < ActiveRecord::Base
    has_many :appointments
    has_many :walkers, through: :appointments
    attr_accessor :prompt, :dog_names, :appt_date, :appt_time

    def self.see_dogs(walker_name)
        @prompt = TTY::Prompt.new
        answer = @prompt.select("Would you like to see all our available dogs?", "Yes", "No")

        if answer == "Yes"
            puts "Great! Let's see those pups."
            Dog.all_dogs(walker_name)
        else
            puts "Boo hoo."
            Walker.choose_action(walker_name)
        end
    end 

    def self.all_dogs(walker_name)
        @dog_names = Dog.all.map { |dog|
            dog.name
        }
        puts "Here are all our available dogs: #{@dog_names.join(", ")}"

        Dog.dog_info(walker_name)
    end

    def self.dog_info(walker_name)
        selected_dog = @prompt.select("Which dog would you like to walk?", @dog_names)

        dog_age = Dog.find_by(name: selected_dog).age
        dog_breed = Dog.find_by(name: selected_dog).breed
        puts "#{selected_dog} is #{dog_age}-years old and a #{dog_breed}."

        Appointment.make_appointment(selected_dog, walker_name)
    end

    def self.see_dogs_walked(walker_name)
        walker = Walker.find_by(name: walker_name)
        if walker.appointments.length > 0
            walked_dogs = walker.appointments.map { |appointment|
                appointment.dog.name
            }

            puts "You've walked #{walked_dogs.length} dogs: #{walked_dogs.join(", ")}!"
        else
            puts "You haven't walked any dogs."
            Appointment.no_appts(walker_name)
        end
    end

end