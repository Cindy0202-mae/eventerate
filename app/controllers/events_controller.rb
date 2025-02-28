class EventsController < ApplicationController
  before_action :skip_authorization, only: [:show, :preview_event_plan, :save_event_plan]
  before_action :set_event, only: [:show, :edit, :update, :preview_event_plan, :save_event_plan, :regenerate_activities]

  # def index
  #   @events = policy_scope(Event).order(date: :asc)
  #   @event = Event.all
  #   @event = Event.new
  # end
  def show
    @event = Event.find(params[:id])
    @users = @event.organization.users
    @task = @event.tasks.new
  end

  def new
    @event = Event.new
    authorize @event
  end

  def create
    @event = Event.new(event_params)
    # @event.age_range = params[:event][:age_range]
    # @event.num_activities = params[:event][:num_activities]
    @event.user = current_user
    @event.organization = Organization.find(current_user.organization_users.first.organization_id)
    authorize @event
    # raise
    if @event.save
      # Initializes a chat with the creator of the event to start off with
      ChatService.create_event_chat(@event, current_user)
      # @event.generate_activities
      # redirect_to @event, notice: 'Event was successfully created.'
      session[:age_range] = params[:event][:age_range]
      session[:num_activities] = params[:event][:num_activities]

      @event.generate_activities_from_ai(session[:age_range], session[:num_activities])
      redirect_to preview_event_plan_event_path(@event)
    else
      Rails.logger.info @event.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  # raise
  # def preview_event_plan
  #   raise
  #   # @event = Event.find(params[:id])
  #   authorize @event
  #   age_range = session[:age_range]
  #   num_activities = session[:num_activities].to_i

  #   Rails.logger.info "🔥 Calling AI with Age Range: #{age_range}, Num Activities: #{num_activities}"

  #   @generated_activities = @event.generate_activities_from_ai(age_range, num_activities)
  #   # Store activities that the user already selected
  #   @selected_activities = @event.activities
  #   # raise
  # end

  def preview_event_plan
    authorize @event
    age_range = session[:age_range]
    num_activities = session[:num_activities].to_i
    @generated_activities = @event.generate_activities_from_ai(age_range, num_activities)
  end

  def save_event_plan
    all_activities = params[:activities] || []
    all_activities.each do |activity_data|
      activity = Activity.create!(
        title: activity_data["title"],
        description: activity_data["description"],
        genres: JSON.parse(activity_data["genres"]),
        age: activity_data["age"]
      )
      ActivitiesEvent.create!(activity: activity, event: @event)
    end
    flash[:notice] = "Event plan saved successfully!"
    redirect_to event_path(@event)
  end

  def regenerated_activities
    @event = Event.find(params["event_id"])
    authorize @event
    count = session[:num_activities].to_i
    ages = session[:age_range]

    selected_titles = params[:selected_activity_titles] || []
    @selected_activities = params[:activities].select { |activity| selected_titles.include?(activity["title"]) }

    remaining = count - @selected_activities.count
    if remaining > 0
      @generated_activities = @event.generate_activities_from_ai(ages, remaining)
    end
  end

  def edit
    @event = Event.find(params[:id])
    authorize @event
  end

  def update
    @event = Event.find(params[:id])
    authorize @event
    if @event.update(event_params)
      redirect_to event_path(@event)
    else
      render :show
    end
  end

  # Preview presentation
  def preview_event
    @event = Event.new(event_params)
    authorize @event
    @generated_activities = PreviewEventFluffService.get_initial_activities
    @tasks = PreviewEventFluffService.get_initial_tasks
  end

  def regenerated_preview
    @event = Event.last
    authorize @event
    @selected_activities = PreviewEventFluffService.get_saved_activities
    @generated_activities = PreviewEventFluffService.get_regenerated_activities
    @saved_tasks = PreviewEventFluffService.get_saved_tasks

    regenerated_titles = @generated_activities.map { |activity| activity["title"] }
    @regenerated_tasks = PreviewEventFluffService.get_regenerated_tasks.select { |key, _| regenerated_titles.include?(key.to_s) }
    @tasks = @regenerated_tasks.merge(PreviewEventFluffService.get_saved_tasks)
  end

  private

  def event_params
    params.require(:event).permit(:title, :duration, :date, :num_activities, :age_range)
  end

  # def activity_params
  #   params.require(:activities_event).permit(:custom_title, :custom_description)
  # end

  def set_event
    @event = Event.find(params[:id])
  end

  def authorize_event
    authorize @event
  end
end
