require 'redmine/scm/adapters/subversion_adapter'

module Redmine
  module Scm
    module Adapters
      class SubversionAdapter
        BRANCHES_PREFIX = [{name: '/trunk',    next_count: 0},
                           {name: '/branches', next_count: 1},
                           {name: '/tags',     next_count: 1},
                           {name: '/sandbox',  next_count: 1},
                           {name: '',          next_count: 1}]

        def svn_repos_prefix_settings
          repos_prefix = Setting.plugin_redmine_revision_branches['svn_repos_prefix']
          if repos_prefix.nil? or (repos_prefix == '')
            settings = Array.new
          else
            settings = repos_prefix.split(',')
          end
          settings << ''
        end

        def get_branch_name(path)
          svn_repos_prefix_settings.each do |repo|
            BRANCHES_PREFIX.each do |branch_prefix|
              pre = repo + branch_prefix[:name]
              next if not path.start_with?(pre)

              case branch_prefix[:next_count]
              when 0
                name = path.match(pre).to_s
              when 1
                path = path + '/'
                name = path.match(pre + '\/(.*?)\/').to_s.chop
              end
              name.slice!(repo)
              return name
            end
          end
          return ''
        end

        def branch_contains(hash)
          identifier = (hash && hash.to_i > 0) ? hash.to_i : "HEAD"
          cmd = "#{self.class.sq_bin} log --xml -v -q -r #{identifier}"
          cmd << credentials_string
          cmd << ' ' + target
          xml = ''
          begin
            shellout(cmd) do |io|
              xml = parse_xml(io.read.force_encoding('UTF-8'))
            end
          rescue ScmCommandAborted
          end

          branches = Array.new
          each_xml_element(xml['log'], 'logentry') do |logentry|
            each_xml_element(logentry['paths'], 'path') do |path|
              branches << get_branch_name(path['__content__'])
            end if logentry['paths'] && logentry['paths']['path']
          end
          branches.select! {|b| b != ''}
          branches.uniq
        end
      end
    end
  end
end
