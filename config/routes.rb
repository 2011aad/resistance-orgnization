Rails.application.routes.draw do
  get 'games/index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'games#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get 'games/create' => 'games#create'
  get 'games/join_game' => 'games#join_game'
  post 'games/start_game' => 'games#start_game'
  get 'games/password' => 'games#password'
  post 'games/choose_seat' => 'games#choose_seat'
  get 'games/play' => 'games#play'
  get 'games/waiting_to_start' => 'games#waiting_to_start'
  get 'games/choose_team_member' => 'games#choose_team_member'
  post 'games/team_info' => 'games#team_info'
  get 'games/voting' => 'games#voting'
  post 'games/collect_votes' => 'games#collect_votes'
  get 'games/tasking' => 'games#tasking'
  get 'games/waiting' => 'games#waiting'
  get 'games/spy_win' => 'games#spy_win'
  get 'games/resistant_win' => 'games#resistant_win'
  post '/games/collect_tasks' => 'games#collect_tasks'
  post '/games/restart' => 'games#restart'
  get '/games/show_task_result' => 'games#show_task_result'
  get '/games/show_vote_result' => 'games#show_vote_result'
  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
