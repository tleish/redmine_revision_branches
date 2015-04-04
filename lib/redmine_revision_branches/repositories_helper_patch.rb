# patch for RepositoriesHelper

RepositoriesHelper.class_eval do

  def linkify_id(html)
    return html unless @repository.identifier.present?
    revision_link = link_to(@rev, {:controller => 'repositories',
                                   :action => 'show',
                                   :id => @project,
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
      td = content_tag(:td, "#{l(:label_branch)}&nbsp;&nbsp;&nbsp;".html_safe)
      td << content_tag(:td) do
        branch_html = content_tag(:b, "#{@repository.identifier}@ ")
        branch_html << links_to_branches.join(', ').html_safe
      end
    end
  end

  def links_to_branches
    return [] unless has_branch_detail?
    @repository.scm.branch_contains(@rev).map do |branch|
      link_to(branch, {:controller => 'repositories',
                       :action => 'show',
                       :id => @project,
                       :repository_id => @repository.identifier,
                       :path => to_path_param(@path),
                       :rev => branch})
    end
  end
end
