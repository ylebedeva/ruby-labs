# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all
profiles = Profile.create! [
	{first_name: 'Carly', last_name: 'Fiorina', gender: 'female', birth_year: 1954},
	{first_name: 'Donald', last_name: 'Trump', gender: 'male', birth_year: 1946},
	{first_name: 'Ben', last_name: 'Carson', gender: 'male', birth_year: 1951},
	{first_name: 'Hillary', last_name: 'Clinton', gender: 'female', birth_year: 1947}
]

dueDate = Date.today + 1.year

profiles.each do |profile|
	user = profile.create_user! username: profile.last_name
	todoList = user.todo_lists.create!(list_due_date: dueDate)
	todoList.todo_items.create! [{title: 'Title', description: 'Description', due_date: dueDate}].cycle(5).to_a
end