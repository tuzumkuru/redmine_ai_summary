# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :issues do
    resources :ai_summaries, only: [:create, :update]
  end
  