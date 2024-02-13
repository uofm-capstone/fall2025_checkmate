module ApplicationHelper
    def active_class(path)
        request.path == path ? 'active' : ''
    end

    # This method creates a link with `data-id` and `data-fields` attributes.
    # These attributes are used to create new instances of the nested fields through JavaScript.
    def link_to_add_fields(name, f, association)
        # Create a new instance of the associated model
        new_object = f.object.send(association).klass.new
        id = new_object.object_id

        # Generate nested fields for the associated model
        fields = f.fields_for(association, new_object, child_index: id) do |builder|
            render(association.to_s.singularize + "_fields", f: builder)
        end

        # Render a link with data attributes for the new instance
        link_to(name, '#', class: "add_fields btn btn-secondary", data: {id: id, fields: fields.gsub("\n", "")})
    end
end
