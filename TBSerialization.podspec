Pod::Spec.new do |s|
	s.name		= "TBSerialization"
	s.version	= "0.0.7"
	s.summary 	= "A JSON to NSManagedObject serializer."
	s.homepage	= "https://github.com/theocalmes/TBSerialization.git"
	s.license	= 'MIT'
	s.author 	= {"Theodore Calmes" => "theo@thoughtbot.com"}
	s.source    = { 
    	:git => "https://github.com/theocalmes/TBSerialization.git", :tag => "0.0.7"
  	}
  	s.source_files = 'TBSerialization/**/*.{m,h}'
	s.requires_arc = true
	s.framework    = 'CoreData'
	s.platform     = :ios, '6.0'
end
