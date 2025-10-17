# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :issues do
  resources :ai_summaries, only: [:create] do
    get :content, on: :collection
  end
end