Rails.application.routes.draw do
  get 'admin/dashboard'
  root to: 'pages#home'
  devise_for :users
  # resources :sprints


  # Webhook for Commit Tracking
  post '/github/webhook', to: 'github#webhook'
  
  # Student List Add controller
  post '/import/home', to: 'student_list_add#import_home'

  # Semester controller
  get 'semesters', to: 'semesters#home', as: 'semesters'
  post 'semesters', to: 'semesters#create'
  get 'semesters/new', to: 'semesters#new', as: 'new_semester'
  get 'semesters/:id/edit', to: 'semesters#edit', as: 'edit_semester'
  get 'semesters/:id', to: 'semesters#show', as: 'semester'
  get 'semesters/:id/status', to: 'semesters#status', as:'semester_status'
  patch 'semesters/:id', to: 'semesters#update'
  delete 'semesters/:id', to: 'semesters#destroy'
  get 'semesters/:semester_id/team/', to: "semesters#team", as: 'semester_team'
  get 'semesters/:id/classlist', to: 'semesters#classlist', as: 'semester_classlist' 
  post 'semesters/:id/upload_sprint_csv', to: 'semesters#upload_sprint_csv', as: 'upload_sprint_csv_semester'

  # Student controller
  get 'students', to: 'students#index', as: 'students'
  post 'students', to: 'students#create'
  get 'students/new', to: 'students#new', as: 'new_student'
  get 'students/:id/edit', to: 'students#edit', as: 'edit_student'
  get 'students/:id', to: 'students#show', as: 'student'
  patch 'students/:id', to: 'students#update'
  delete 'students/:id', to: 'students#destroy', as: 'destroy_student'




  # Sprint controller
  get 'semesters/:semester_id/sprints', to: 'sprints#index', as: 'semester_sprints'
  post 'semesters/:semester_id/sprints', to: 'sprints#create'
  get 'semesters/:semester_id/sprints/new', to: "sprints#new", as: 'new_semester_sprint'
  get 'sprint_dates', to: 'sprint#get_git_info'
  get 'semesters/:semester_id/sprints/:id', to: 'sprints#show', as: 'semester_sprint'
  patch 'semesters/:semester_id/sprints/:id', to: 'sprints#update'
  delete 'semesters/:semester_id/sprints/:id', to: 'sprints#destroy'
  put 'semesters/:semester_id/sprints/:id', to: 'sprints#update'
  get 'semesters/:semester_id/sprints/:id/edit', to: 'sprints#edit', as: 'edit_semester_sprint'

  # Team controller
  resources :teams do
    member do
      post 'add_member'
      delete 'remove_member'
    end
  end

  # Admin controller
  get 'admin_dashboard', to: 'admin#dashboard', as: 'admin'
  delete 'admin_user/:id', to: 'admin#destroy', as: 'admin_delete_user'
  patch 'admin_user/:id/role', to: 'admin#update_role', as: 'admin_update_role'

  # Pages controller
  get 'home', to: 'pages#home', as: 'home'
  
  resources :semesters do
    resources :repositories, only: [:new, :create, :show], controller: 'semesters/repositories'
  end
end

