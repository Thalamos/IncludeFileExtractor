require 'asciidoctor'
require 'asciidoctor/extensions'

class IncludeFileProcessor < Asciidoctor::Extensions::IncludeProcessor
    use_dsl

    @@new_file = false
    @@include_file_name = "includes"
    @@attr_includes_file_name = "ife_filename"
    @@attr_nolinesinclude = "ife_nolinesinclude"
    @@nolinesinclude_tag_attr = "lines"

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

        hasLinesInclude = false

        attribute.each do |key, val|
            if key.to_s.start_with?(@@nolinesinclude_tag_attr)
                hasLinesInclude = true
                break
            end
        end

        unless doc.attributes[@@attr_nolinesinclude] && hasLinesInclude
            File.open(@@include_file_name, "a") do |f|
                f.write target + "\n"
            end
        end

        content = IO.readlines target 
        reader.push_include content, target, target, 1, attribute
        reader
    end

    def handles? target
        true
    end
end

class IncludeFilePostprocessor < Asciidoctor::Extensions::Postprocessor
    def process doc, output
        #begin
        #    exit 0
        #rescue SystemExit
        #    return 0
        #end
        exit!(true)
    end
end

Asciidoctor::Extensions.register :include_file_processor do 
    include_processor IncludeFileProcessor
end

Asciidoctor::Extensions.register :include_file_postprocessor do
    postprocessor IncludeFilePostprocessor
end

