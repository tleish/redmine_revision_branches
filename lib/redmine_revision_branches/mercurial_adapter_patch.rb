require 'redmine/scm/adapters/mercurial_adapter'

module Redmine
  module Scm
    module Adapters
      class MercurialAdapter
        def branch_contains(hash)
          cleaned_hash = hash.sub(/[^\w]/, '')
          contains_filter = "descendants(%s) and heads(all()) and not closed()" % cleaned_hash
          cmd_args = ['log', '-r', contains_filter, '-T', '{branch}\n']
          begin
            branches = hg(*cmd_args) do |io|
              io.readlines.sort!.map{|t| t.strip.gsub(/\* ?/, '')}
            end
          rescue ScmCommandAborted
            branches = Array.new
          end
          branches.uniq
        end
      end
    end
  end
end
