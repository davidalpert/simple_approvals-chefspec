# simple_approvals/chefspec

a simple chefspec-based implementation of the ApprovalTests pattern

## Usage

1. Update your `Gemfile` to include:

    ```ruby
    gem 'simple_approvals-chefspec'
    ```

1. Update `spec_helper.rb` to include:

    ```ruby
    require 'simple_approvals/chefspec'
    ```

1. Add a single template approval like this:

    ```ruby
    describe 'my-cookbook::my-recipe' do
      include ChefVault::TestFixtures.rspec_shared_context
      context 'When all attributes are default, on CentOS 7.4.1708' do
        let(:chef_run) do
          # for a complete list of available platforms and versions see:
          # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
          runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '7.4.1708') do |node, server|
            node.override['my-cookbook']['attribute1'] = true
          end
          runner.converge(described_recipe)
        end


        it 'converges successfully' do
          expect { chef_run }.to_not raise_error
        end

        verify_chef_template(
          expected_path: '/path/to/rendered/template',
          approved_path: 'local/path/to/approved/template/output' # e.g. test/fixtures/approvals/logfile.xml
        )
      end
    end
    ```

1. Add multiple template approvals like this:

    ```ruby
    describe 'my-cookbook::my-recipe' do
      include ChefVault::TestFixtures.rspec_shared_context
      context 'When all attributes are default, on CentOS 7.4.1708' do
        let(:chef_run) do
          # for a complete list of available platforms and versions see:
          # https://github.com/customink/fauxhai/blob/master/PLATFORMS.md
          runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '7.4.1708') do |node, server|
            node.override['my-cookbook']['attribute1'] = true
          end
          runner.converge(described_recipe)
        end


        it 'converges successfully' do
          expect { chef_run }.to_not raise_error
        end

        verify_chef_templates(
          { expected_path: '/path/to/rendered/template1',
            approved_path: 'local/path/to/approved/template/output1' # e.g. test/fixtures/approvals/logfile1.xml
          },
          { expected_path: '/path/to/rendered/template2',
            approved_path: 'local/path/to/approved/template/output2' # e.g. test/fixtures/approvals/logfile2.xml
          }
        )
      end
    end
    ```

## Development

1. make changes
2. bump `VERSION`
3. `gem build simple_approvals-chefspec.gemspec`
4. `gem push simple_approvals-chefspec-1.0.0.gem`
