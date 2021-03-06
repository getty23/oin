def generate_links name, parameters
  
  plural = name.to_s.pluralize
  singular = plural.singularize
  
  namespaces = parameters[:namespaces]
  prefix = parameters[:prefix]
  postfix = parameters[:postfix]
  collections = parameters[:collections]
  members = parameters[:members]
  titles = parameters[:titles]
  parameters = parameters[:parameters]
  
  namespaces.class == Array || namespaces = [namespaces]
  namespaces = namespaces.compact
  
  if namespaces.empty?
    extended_plural = plural
    extended_singular = singular
  else
    extended_plural = namespaces.join("_")+"_"+plural
    extended_singular = namespaces.join("_")+"_"+singular
  end
  
  
  parameters.class == Array || parameters = [parameters]
  
  plural_parameters = parameters
  singular_parameters = parameters+[singular]
  
  generate_link extended_plural, :prefix => prefix, :postfix => postfix, :parameters => plural_parameters, :title => titles[:index]
  generate_link extended_singular, :prefix => prefix, :postfix => postfix, :parameters => singular_parameters, :title => titles[:show]
  generate_link "new_"+extended_singular, :prefix => prefix, :postfix => postfix, :parameters => plural_parameters, :title => titles[:new]
  generate_link "edit_"+extended_singular, :prefix => prefix, :postfix => postfix, :parameters => singular_parameters, :title => titles[:edit]
  generate_link "destroy_"+extended_singular, :url => extended_singular+"_path", :prefix => prefix, :postfix => postfix, :parameters => singular_parameters, :title => titles[:destroy], :html_options => {:confirm => "Sind sie sicher, dass sie \#{#{singular}.title} löschen möchten?", :method => :delete}
  
  if collections
    collections.class == Array || collections = [collections]
    collections.each do |collection|
      generate_link collection.to_s+"_"+extended_plural, :prefix => prefix, :postfix => postfix, :parameters => plural_parameters, :title => titles[collection]
    end
  end
  
  if members
    members.class == Array || members = [members]
    members.each do |member|
      generate_link member.to_s+"_"+extended_singular, :prefix => prefix, :postfix => postfix, :parameters => singular_parameters, :title => titles[member]
    end
  end
  
end




# generate_link :project, :namespaces => :workspace, :prefix => :a, :postfix => "with_user_login_as_title", :url => :user_project_path, :parameters => [:user, :project], :title => "\#{user.login}", html_options => {:confirm => "Sind sie sicher, dass sie das Projekt \#{project.title} anzeigen lassen möchten?"}
#
# generates
#
# def link_to_a_workspace_project_with_user_login_as_title(project, user)
#   Link.new("#{user.login}", user_project_path(user, project), {:confirm => "Sind sie sicher, dass sie das Projekt #{project.title} anzeigen lassen möchten?"})
# end
#
# and the correspondending active_link_to_a_workspace_project_with_user_login_as_title
#
# Leave out fields you do not need (e. g. :prefix)
# If :url is not specified, namespaces+name+"_path" is used (in this example: workspace_project_path)
# parameters must be specified in correct order in an array (if not single)

def generate_link name, parameters
  
  name = name.to_s
  
  url = parameters[:url]
  namespaces = parameters[:namespaces]
  parameters[:prefix] ? prefix = parameters[:prefix].to_s+"_" : prefix = ""
  parameters[:postfix] ? postfix = "_"+parameters[:postfix].to_s : postfix = ""
  title = parameters[:title].to_s
  html_options = parameters[:html_options]
  parameters = parameters[:parameters]
  
  namespaces.class == Array || namespaces = [namespaces]
  namespaces = namespaces.compact
  
  if namespaces.empty?
    extended_name = name
  else
    extended_name = namespaces.join("_")+"_"+name
  end
  
  method_name = "link_to_"+prefix+extended_name+postfix
  
  parameters.class != Array || parameters = parameters.compact.join(", ")
  
  url ||= extended_name+"_path"
  if url.class == Hash
  	url = url.inspect
  else
  	url = url.to_s
  	url += "(#{parameters})"
  end
  
  html_options ||= {}
  html_options = html_options.merge({:class => "link"})
  
  puts "def #{method_name}(#{parameters}); Link.new #{title.inspect.sub /\\#/, "#"}, #{url.sub /\\#/, "#"}, #{html_options.inspect.sub /\\#/, "#"}; end;"
  
  module_eval "def #{method_name}(#{parameters}); Link.new #{title.inspect.sub /\\#/, "#"}, #{url.sub /\\#/, "#"}, #{html_options.inspect.sub /\\#/, "#"}; end;"
  
  method_name = "active_"+method_name
  html_options[:class] = "active "+html_options[:class]
  
  module_eval "def #{method_name}(#{parameters}); Link.new #{title.inspect.sub /\\#/, "#"}, #{url.sub /\\#/, "#"}, #{html_options.inspect.sub /\\#/, "#"}; end;"
  
end




class ApplicationController < ActionController::Base
  
  include AuthenticatedSystem
  
  protect_from_forgery
  
  helper :all
  
  
  
  
  class Link
    attr_reader :title, :url, :html_options
    def initialize(title, url = {}, html_options = {})
      @title = title
      @url = url
      @html_options = html_options
    end
  end
  
  class SelectOption
    attr_reader :title, :value
    def initialize(title, value)
      @title = title
      @value = value
    end
  end
  
  
  
  
  project_titles = {:index => "Projekte", :new => "Neues Projekt", :show => "\#{project.title}", :edit => "Projekt bearbeiten", :destroy => "Projekt löschen"}
  task_titles = {:index => "Aufgaben", :new => "Neue Aufgabe", :edit => "Aufgabe bearbeiten", :destroy => "Aufgabe löschen"}
  appointment_titles = {:index => "Termine", :new => "Neuer Termin", :edit => "Termin bearbeiten", :destroy => "Termin löschen"}
  messages_titles = {:index => "Nachrichten", :show => "\#{message.title}", :new => "Neue Nachricht"}
  project_member_titles = {:index => "Kollegen", :authorize => "Authorisierungsanfragen"}
  
  with_project_title_titles = {:index => "\#{project.title}"}
  
  
  
  
  generate_link :login, :title => "Anmeldung"
  
  generate_links :projects, :titles => project_titles
  
  generate_link :workspace, :title => "Mein Arbeitsbereich"
  generate_links :projects, :namespaces => :workspace, :titles => project_titles
  generate_links :bulletin_board_messages, :namespaces => [:workspace, :project], :parameters => :project, :titles => {:index => "Pinnwand", :new => "Neuer Pinnwandeintrag", :edit => "Pinnwandeintrag bearbeiten"}
  generate_links :bulletin_board_messages, :namespaces => [:workspace, :project], :parameters => :project, :postfix => "with_project_title", :titles => with_project_title_titles
  generate_links :tasks, :namespaces => :workspace, :titles => task_titles
  generate_links :tasks, :namespaces => :workspace, :postfix => "with_project_title", :titles => with_project_title_titles
  generate_links :tasks, :namespaces => [:workspace, :project], :parameters => :project, :titles => task_titles
  generate_links :tasks, :namespaces => [:workspace, :project], :postfix => "with_project_title", :parameters => :project, :titles => with_project_title_titles
  generate_links :appointments, :namespaces => :workspace, :titles => appointment_titles
  generate_links :appointments, :namespaces => :workspace, :postfix => "with_project_title", :titles => with_project_title_titles
  generate_links :appointments, :namespaces => [:workspace, :project], :parameters => :project, :titles => appointment_titles
  generate_links :appointments, :namespaces => [:workspace, :project], :postfix => "with_project_title", :parameters => :project, :titles => with_project_title_titles
  generate_link :messages, :namespaces => :workspace, :title => "Nachrichten"
  generate_link :messages, :namespaces => [:workspace, :project], :parameters => :project, :title => "Nachrichten"
  generate_link :create_project_member, :url => :workspace_project_project_members_path, :parameters => :project, :title => "Projekt beitreten", :html_options => {:method => :post}
  generate_links :project_members, :namespaces => [:workspace], :collections => :authorize, :titles => project_member_titles
  generate_links :project_members, :namespaces => [:workspace], :postfix => "with_project_title", :collections => :authorize, :titles => with_project_title_titles
  generate_links :project_members, :namespaces => [:workspace, :project], :collections => :authorize, :parameters => :project, :titles => project_member_titles
  generate_links :project_members, :namespaces => [:workspace, :project], :postfix => "with_project_title", :collections => :authorize, :parameters => :project, :titles => with_project_title_titles
  
	# Flos links
	
	uploads_titles = {:index => "Uploads", :new => "Neuer Upload"}
	
	generate_link :signup, :title => "Registrieren"
	
  generate_link  :user, :title => {:index => "\#{user.login}"}, :parameters => :user
	generate_links :user_details, :namespaces => :user, :titles => {:edit => "Profil bearbeiten", :show => "Profil anzeigen"}
	generate_links :messages, :titles => messages_titles
	
	
	generate_link :box, :parameters => :type, :url => {:controller => "messages", :action => "box", :type => type}, :title => "\#{type}"
	generate_links :innovations, :titles => {:index => "Innovationen", :show => "\#{innovation.title}", :new => "Neue Innovation", :edit => "Innovation bearbeiten", :destroy => "Innovation löschen"}
	generate_link :show_all_innovations, :url => {:controller => "innovations", :action => "show_all", :title => "\#{title}", :order => "created_at", :direction => "DESC"}, :parameters => :title, :title => "\#{title}"
	generate_links :uploads, :namespaces => :innovation, :parameters => :inno, :titles => uploads_titles
	generate_links :ideas, :titles => {:index => "Ideen", :show => "\#{idea.title}", :new => "Neue Idee", :edit => "Idee bearbeiten", :destroy => "Idee löschen"}
	generate_link :show_all_ideas, :url => {:action => "show_all", :title => "\#{title}", :order => "\#{order}", :direction => "\#{direction}", :condition => "\#{condition}", :offset => "\#{offset}", :limit => "\#{limit}", :page => 1}, :parameters => [:title, :order, :direction, :condition, :offset, :limit], :title => "\#{title}"
	generate_links :uploads, :namespaces => :idea, :parameters => :idea, :titles => uploads_titles
	
	
	generate_link :main, :title => "Home"
  
  
  
  
  before_filter :initialize_project_variables
  
  before_filter :create_navigation
  before_filter :create_subnavigation
  before_filter :create_path
  
  
  
  
  def initialize_project_variables
    project_id = params[:project_id]
    if params[:controller] == "projects" || params[:controller] == "workspace"
     project_id = params[:id]
    end
    @project = Project.find_by_id(project_id)
    if @project
      project_member = @project.project_members.find_by_user_id(current_user)
      @is_project_member = project_member
      @is_authorized_project_member = @is_project_member && project_member.is_authorized
      @is_project_admin = @is_authorized_project_member && project_member.is_admin
    else
      @is_project_member = false
      @is_authorized_project_member = false
      @is_project_admin = false
    end
  end
  
  
  
  
  def project_member_required
    if !@is_project_member
      flash[:notice] = "Sie haben nicht die erforderlichen Rechte, um diese Seite aufzurufen."
      redirect_back_or_default("/")
    end
  end
  
  def project_authorization_required
    if !@is_authorized_project_member
      flash[:notice] = "Sie haben nicht die erforderlichen Rechte, um diese Seite aufzurufen."
      redirect_back_or_default("/")
    end
  end
  
  def project_admin_required
    if !@is_project_admin
      flash[:notice] = "Sie haben nicht die erforderlichen Rechte, um diese Seite aufzurufen."
      redirect_back_or_default("/")
    end
  end
  
  def restricted_project_authorization_required
    !@project || project_authorization_required
  end
  
  def is_project_member(project)
    return project.project_members.find_by_user_id(current_user)
  end
  
  def is_authorized_project_member(project)
    return project.project_members.find_by_user_id_and_is_authorized(current_user, true)
  end
  
  def is_project_admin(project)
    return project.project_members.find_by_user_id_and_is_admin(current_user, true)
  end
  
  
  
  
  def create_navigation
    params[:controller] == "ideas" ? @navigation = [active_link_to_ideas] : @navigation = [link_to_ideas]
    params[:controller] == "projects" ? @navigation += [active_link_to_projects] : @navigation += [link_to_projects]
    if logged_in?
      if params[:controller] == "workspace" || params[:controller] == "bulletin_board_messages" || params[:controller] == "tasks" || params[:controller] == "project_members"
        !@project ? group = [active_link_to_workspace] : group = [link_to_workspace]
      else
        group = [link_to_workspace]
      end
      current_user.projects.each do |project|
        if is_authorized_project_member(project)
          case params[:controller]
          when "workspace"
            project == @project ? group += [active_link_to_workspace_project(project)] : group += [link_to_workspace_project(project)]
          when "bulletin_board_messages"
            project == @project ? group += [active_link_to_workspace_project_bulletin_board_messages_with_project_title(project)] : group += [link_to_workspace_project_bulletin_board_messages_with_project_title(project)]
          when "tasks"
            project == @project ? group += [active_link_to_workspace_project_tasks_with_project_title(project)] : group += [link_to_workspace_project_tasks_with_project_title(project)]
          when "project_members"
            case params[:action]
            when "index"
              project == @project ? group += [active_link_to_workspace_project_project_members_with_project_title(project)] : group += [link_to_workspace_project_project_members_with_project_title(project)]
            when "authorize"
              project == @project ? group += [active_link_to_authorize_workspace_project_project_members_with_project_title(project)] : group += [link_to_authorize_workspace_project_project_members_with_project_title(project)]
            end
          else
            group += [link_to_workspace_project(project)]
          end
        else
          project == @project ? group += [active_link_to_workspace_project(project)] : group += [link_to_workspace_project(project)]
        end
      end
      @navigation += [group]
    end
    params[:controller] == "innovations" ? @navigation += [active_link_to_innovations] : @navigation += [link_to_innovations]
  end
  
  def create_subnavigation
    @subnavigation = []
  end
  
  def create_path
    @path = [Link.new("")]
  end
  
  
  
  
  def create_workspace_subnavigation(links = nil)
    if @project
      if @is_authorized_project_member
        params[:controller] == "bulletin_board_messages" ? @subnavigation = [links] : @subnavigation = [link_to_workspace_project_bulletin_board_messages @project]
        params[:controller] == "tasks" ? @subnavigation += [links] : @subnavigation += [link_to_workspace_project_tasks @project]
        params[:controller] == "appointments" ? @subnavigation += [links] : @subnavigation += [link_to_workspace_project_appointments @project]
        params[:controller] == "messages" ? @subnavigation += [active_link_to_workspace_project_messages @project] : @subnavigation += [link_to_workspace_project_messages @project]
        params[:controller] == "project_members" && params[:action] == "index" ? @subnavigation += [active_link_to_workspace_project_project_members @project] : @subnavigation += [link_to_workspace_project_project_members @project]
        params[:controller] == "project_members" && params[:action] == "authorize" ? @subnavigation += [active_link_to_authorize_workspace_project_project_members @project] : @subnavigation += [link_to_authorize_workspace_project_project_members @project]
      else
        @subnavigation = []
      end
    else
      params[:controller] == "tasks" ? @subnavigation = [links] : @subnavigation = [link_to_workspace_tasks]
      params[:controller] == "appointments" ? @subnavigation += [links] : @subnavigation += [link_to_workspace_appointments]
      params[:controller] == "messages" ? @subnavigation += [active_link_to_workspace_messages] : @subnavigation += [link_to_workspace_messages]
      params[:controller] == "project_members" && params[:action] == "index" ? @subnavigation += [active_link_to_workspace_project_members] : @subnavigation += [link_to_workspace_project_members]
      params[:controller] == "project_members" && params[:action] == "authorize" ? @subnavigation += [active_link_to_authorize_workspace_project_members] : @subnavigation += [link_to_authorize_workspace_project_members]
    end
  end
  
  
  
  
  # This is a class to get all ideas with a certain order, condition...
	# important for the ideas controller and the show_all method

	class Ideas
		
		def initialize(order, direction, condition, offset, limit)
			@order = order
			@direction = direction
			@condition = condition
			@offset = offset
			@limit = limit

			if order != "rating"
				@ideas = Idea.find(:all, :order => order+" "+direction, :conditions => condition)
			else
				@ideas = Idea.find(:all, :conditions => condition)
				@ideas = @ideas.sort_by {|i| [i.get_rating]}.reverse
			end

			@count = @ideas.size.to_f
			@pages = (@count / @limit.to_i).ceil
			@page_now = 1
			
		end

		attr_accessor :offset, :limit, :pages, :page_now

		def ideas
			return @ideas.slice(((@page_now-1)*@limit)..(@page_now*@limit)-1)
		end
		
		def ideas_page(page)
			return @ideas.slice(((page-1)*@limit)..(page*@limit)-1)		
		end
		
		def next_page?
			if @page_now + 1 <= @pages
				return true
			else
				return false
			end
		end

		def next_page
			if @page_now + 1 <= @pages
				@page_now = @page_now + 1
			end
		end

		def prev_page?
			if @page_now - 1 > 0
				return true
			else
				return false
			end
		end

		def prev_page
			if @page_now - 1 > 0
				@page_now = @page_now -1
			end
		end
	end
  
end
