require 'asciidoctor/extensions'

class IncludeFileExtractor < Asciidoctor::Extensions::IncludeProcessor
    use_dsl

    @@new_file = false
    @@include_file_name = "includes"
    @@attr_includes_file_name = "ife_filename"

    def process doc, reader, target, attribute
        
        if doc.attributes[@@attr_includes_file_name]
            unless @@include_file_name == doc.attributes[@@attr_includes_file_name]
                @@include_file_name = doc.attributes[@@attr_includes_file_name]
            end
        end

        unless @@new_file
            if File.exists?(@@include_file_name)
                File.delete(@@include_file_name)
            end
            @@new_file = true
        end

        File.open(@@include_file_name, "a") do |f|
            f.write target + "\n"
        end

        content = IO.readlines target 
        reader.push_include content, target, target, 1, attribute
        reader
    end

    def handles? target
        true
    end
end

Asciidoctor::Extensions.register do 
    include_processor IncludeFileExtractor
end