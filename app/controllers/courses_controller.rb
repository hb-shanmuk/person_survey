class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  # GET /courses
  # GET /courses.json
  def index
    if params[:step].present? && [3,4,5].include?(params[:step].to_i)
      answers = Answer.joins("INNER JOIN questions ON questions.id = answers.question_id").where("answers.user_id = 1").select("questions.category,avg(answers.answer) as answer_avg").order("answer_avg").group("questions.category").limit(3)
      if [3,4].include?(params[:step].to_i)        
        if answers.present? 
          @courses = Question.select("id, category, concat(id,'_',title) AS question").where("id NOT IN (?) AND category = ?",Answer.select("question_id").where("user_id = 1").map(&:question_id),answers.first.category).order("RAND()").limit(2)
          category_ids = answers.map(&:category)
          category_ids.delete_at(0)
          @courses += Question.select("id, category, (SELECT concat(id,'_',title) FROM questions WHERE category = questions.category GROUP BY id ORDER BY RAND( ) LIMIT 1) AS question").where("id NOT IN (?) AND category IN (?)",Answer.select("question_id").where("user_id = 1").map(&:question_id),category_ids).group("category")        
        end        
      else
        redirect_to course_path(1,:category=>answers.first.category)
      end
    elsif params[:step].present?  && params[:step].to_i == 2
      @courses = Question.select("id, category, (SELECT concat(id,'_',title) FROM questions WHERE category = questions.category GROUP BY id ORDER BY RAND( ) LIMIT 1) AS question").where("id NOT IN (?)",Answer.select("question_id").where("user_id = 1").map(&:question_id)).group("category")    
    else
      params[:step] ||= 1
      @courses = Question.select("category, (SELECT concat(id,'_',title) FROM questions WHERE category = questions.category GROUP BY id ORDER BY RAND( ) LIMIT 1) AS question").group("category")
      # render :text => 
    end
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
    render :text => params[:category].inspect and return false
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses
  # POST /courses.json
  def create    
    if params[:answer].present?
      if params[:answer].keys.length== 6 && [1,2].include?(params[:step].to_i)      
        # render :text => params.inspect and return false
        params[:answer].each do |key,value|
          Answer.create(:question_id=>key,:answer=>value,:user_id=>1)
        end      
        redirect_to courses_path(:step=>params[:step].to_i+1)
      elsif params[:answer].keys.length==4 && [3,4].include?(params[:step].to_i)
        params[:answer].each do |key,value|
          Answer.create(:question_id=>key,:answer=>value,:user_id=>1)
        end      
        redirect_to courses_path(:step=>params[:step].to_i+1)
      else
         redirect_to courses_path         
      end        
    else
      redirect_to courses_path      
    end
  end

  # PATCH/PUT /courses/1
  # PATCH/PUT /courses/1.json
  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_params
      params[:course]
    end
end
