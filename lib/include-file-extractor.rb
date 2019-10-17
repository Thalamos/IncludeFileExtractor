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

class FileGenerationToggle < Asciidoctor::Extensions::Postprocessor
    @@attr_no_file_generation = "ife_no_adoc_output_files"
    def process doc, output
        if doc.attributes[@@attr_no_file_generation]
            exit!
        end

        output
    end
end

Asciidoctor::Extensions.register do 
    include_processor IncludeFileExtractor
end

Asciidoctor::Extensions.register do
    postprocessor FileGenerationToggle
end
