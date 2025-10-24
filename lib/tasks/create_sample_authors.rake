namespace :authors do
  desc "Create sample authors"
  task create_samples: :environment do
    puts "Creating sample authors..."
    
    authors_data = [
      { name: 'Kim Donghwa', role: 'writer', bio: '30 years of fairy tale writing experience', active: true },
      { name: 'Lee Geurim', role: 'illustrator', bio: 'Illustrator with warm sensibility', active: true },
      { name: 'Park Seongwoo', role: 'narrator', bio: 'Voice loved by children', active: true },
      { name: 'Choi Jakga', role: 'writer', bio: 'Specialized in traditional tales', active: true },
      { name: 'Jung Iller', role: 'illustrator', bio: 'Digital art specialist', active: true }
    ]
    
    authors_data.each do |author_data|
      author = Author.find_or_create_by(name: author_data[:name], role: author_data[:role]) do |a|
        a.bio = author_data[:bio]
        a.active = author_data[:active]
      end
      puts "  #{author.persisted? ? 'Created' : 'Found'}: #{author.name} (#{author.role})"
    end
    
    puts "Total authors: #{Author.count}"
  end
end

