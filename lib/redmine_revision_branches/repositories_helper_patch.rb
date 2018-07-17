# patch for RepositoriesHelper

RepositoriesHelper.class_eval do

  def plugin_redmine_revision_branches(setting)
    return nil unless Setting.plugin_redmine_revision_branches.is_a? Hash
    Setting.plugin_redmine_revision_branches[setting]
  end

  def linkify_id(html)
    return html unless @repository.identifier.present?
    revision_link = link_to(@rev, {:controller => 'repositories',
                                   :action => 'show',
                                   :id => @repository.project,
                                   :repository_id => @repository.identifier,
                                   :path => to_path_param(@path),
                                   :rev => @rev})
    html.sub(content_tag(:td, @rev), content_tag(:td, revision_link)).html_safe
  end

  def has_branch_detail?
    @repository.scm.respond_to? :branch_contains
  end

  def insert_branches_detail(html)
    return html unless has_branch_detail?
    substring = '</tr>'
    location = html.index(substring).to_i + substring.length
    html.insert(location, branches_html)
  end

  def branches_html
    content_tag(:tr) do
      td = content_tag(:td, "#{l(:label_branch)}&nbsp;&nbsp;&nbsp;".html_safe, valign: 'top')
      td << content_tag(:td) do
        branch_html = content_tag(:b, "#{@repository.identifier}@ ")
        branch_html << links_to_branches.join(', ').html_safe
      end
    end
  end

  def links_to_branches
    return [] unless has_branch_detail?
    branch_groups.map { |name, branches| branches_link(name, branches) }
  end

  def branches_link(name, branches)
    return branch_link(branches.first) if branches.length == 1
    link =  link_to("[#{name}...]", 'javascript:;', class: 'scm-branch-group').html_safe
    content_tag(:span, class: 'scm-branch-hide') do
      link << content_tag(:span, class: 'scm-branches') do
        branches.map { |branch| branch_link(branch) }.join(', ').html_safe
      end
    end
  end

  def branch_link(branch)
    if @repository.scm_name == 'Subversion'
      link_to(branch, {:controller => 'repositories',
                       :action => 'show',
                       :id => @repository.project,
                       :repository_id => @repository.identifier,
                       :path => to_path_param(branch)}).html_safe
    else
      link_to(branch, {:controller => 'repositories',
                       :action => 'show',
                       :id => @repository.project,
                       :repository_id => @repository.identifier,
                       :path => to_path_param(@path),
                       :rev => branch}).html_safe
    end
  end

  def branch_groups
    @repository.scm.branch_contains(@rev).group_by do |branch|
      branch.downcase
        .gsub(/^\d+/, '#####')
        .split(/[\-\._]/)
        .first
    end.sort_by { |name, branches| [branches.length, name] }
  end

end
