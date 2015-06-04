Dir["#{Rails.root}/db/seeds/demo/demo_data/*.rb"].each {|file| require file }

puts "Creating demo students, school, homerooms, assessment results..."

School.destroy_all
healey = School.create(name: "Arthur D Healey")

Homeroom.destroy_all
n = 0
4.times do |n|
  Homeroom.create(name: "10#{n}")
  n += 1
end

Student.destroy_all
McasResult.destroy_all
StarResult.destroy_all
DisciplineIncident.destroy_all
AttendanceEvent.destroy_all

36.times do
  student = Student.create(FakeStudent.data)
  student.homeroom_id = Homeroom.all.sample.id
  student.save
  5.times do |n|
    test_date = Time.local(2010 + n, 10, 1)
    # creates a test result once a year on october 1st
    result = McasResult.new(FakeMcasResult.data)
    result.update_attributes({student_id: student.id, date_taken: test_date})
    result.save
    result = StarResult.new(FakeStarResult.data)
    result.update_attributes({student_id: student.id, date_taken: test_date})
    result.save
  end
  discipline_event_generator = Rubystats::NormalDistribution.new(5.2, 8.3)
  absence_event_generator = Rubystats::NormalDistribution.new(8.8, 10)
  tardy_event_generator = Rubystats::NormalDistribution.new(11.9, 16.8)
  # using separate absence and tardy events could mean an absence and tardy occur on the same day.
  30.in(100) do
    # real data indicates only ~7.5% ( 14.in(200) ) of students have discipline incidents in a year
    # increasing proportion here makes data look more interesting for development
    5.times do |n|
      date_begin = Time.local(2010 + n, 8, 1)
      date_end = Time.local(2011 + n, 7, 31)
      discipline_event_generator.rng.round(0).times do
        discipline_incident = DisciplineIncident.new(FakeDisciplineIncident.data)
        discipline_incident.student_id = student.id
        discipline_incident.event_date = Time.at(date_begin + rand * (date_end.to_f - date_begin.to_f))
        discipline_incident.save
      end
    end
  end
  94.in(100) do
    5.times do |n|
      date_begin = Time.local(2010 + n, 8, 1)
      date_end = Time.local(2011 + n, 7, 31)
      absence_event_generator.rng.round(0).times do
        attendance_event = AttendanceEvent.new({absence: true})
        attendance_event.student_id = student.id
        attendance_event.event_date = Time.at(date_begin + rand * (date_end.to_f - date_begin.to_f))
        attendance_event.save
      end
    end
  end
  70.in(100) do
    5.times do |n|
      date_begin = Time.local(2010 + n, 8, 1)
      date_end = Time.local(2011 + n, 7, 31)
      tardy_event_generator.rng.round(0).times do
        attendance_event = AttendanceEvent.new({tardy: true})
        attendance_event.student_id = student.id
        attendance_event.event_date = Time.at(date_begin + rand * (date_end.to_f - date_begin.to_f))
        attendance_event.save
      end
    end
  end
end
