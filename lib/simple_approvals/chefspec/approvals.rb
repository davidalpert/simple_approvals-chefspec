require 'rspec'
require 'chefspec'
require 'simple_approvals/rspec'

module RSpec
  module Core
    # open up ExampleGroup to add template approval helpers
    class ExampleGroup
      class << self
        # This defines a batch of approval expectations which will be executed
        # for each template, because each template can fail for multiple reasons:
        # - not being defined in a recipe (or being defined with a different path)
        # - not rendering in the cookbook (i.e. file does not exist where expected)
        # - rendering with unexpected content
        shared_examples_for 'an approved chef template' do |file|
          describe file[:expected_path] do
            if file[:template]
              it 'defines the template resource' do
                expect(chef_run).to create_template(file[:expected_path])
              end
            end

            it 'renders the expected file' do
              expect(chef_run).to render_file(file[:expected_path])
            end

            it 'renders the expected file with the expected content' do
              verifier = Approvals.chef_template_verifier_for(file[:expected_path], file[:approved_path], scrubber: file[:scrubber], keep_received_file: file[:keep_received_file])
              expect(chef_run).to render_file(file[:expected_path]).with_content(verifier)
            end
          end
        end

        # verify one template:
        #
        #    verify_chef_template(expected_path: '', approved path: '')
        #
        def verify_chef_template(**file)
          file[:template] = true
          file[:scrubber] = ->(rendered_content) { yield rendered_content } if block_given?
          verify_chef_file(**file)
        end

        def verify_chef_file(**file)
          file[:scrubber] = ->(rendered_content) { yield rendered_content } if block_given?
          include_examples 'an approved chef template', file
        end

        # verify a set of templates:
        #
        #     verify_chef_templates(
        #        { expected_path: '',
        #          approved path: ''
        #        },
        #        { expected_path: ''
        #          approved path: ''
        #        }
        #     )
        #
        # note: this requires that rubocop is configued like this:
        #
        #     BracesAroundHashParameters:
        #         EnforcedStyle: context_dependent
        #
        # which is taken care of in the shared lib/.chef-rubocop.yml
        #
        def verify_chef_templates(*specs)
          specs.each do |file|
            file[:scrubber] = ->(rendered_content) { yield rendered_content } if block_given?
            file[:template] = true
            verify_chef_file(file)
          end
        end

        def verify_chef_files(*specs)
          specs.each do |file|
            file[:scrubber] = ->(rendered_content) { yield rendered_content } if block_given?
            verify_chef_file(file)
          end
        end
      end
    end
  end
end

# open SimpleApprovals::Approvals and add a ChefSpec-specific helper
class Approvals
  class << self
    def chef_template_verifier_for(expected_path, approved_path, **options)
      options[:message_override] = %(expected Chef run to render "#{expected_path}" matching "#{approved_path}")

      proc do |rendered_content|
        rendered_content = yield(rendered_content) if block_given?
        rendered_content = options[:scrubber].call(rendered_content) if options[:scrubber]
        verify(rendered_content, approved_path, **options)
      end
    end
  end
end
