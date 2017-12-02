Rails.application.routes.draw do
  get 'inquiry/:id/new', to: 'inquiry#new', as: 'inquiry_new'
  post 'inquiry/:id/confirm', to: 'inquiry#confirm', as: 'inquiry_confirm'
  post 'inquiry/:id/create', to: 'inquiry#create', as: 'inquiry_create'
end
