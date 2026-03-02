require 'sinatra'
require 'bcrypt'
require 'httparty'
require 'json'

SUPABASE_URL = "https://paizbjrlybeaxnziwfvo.supabase.co/rest/v1/usuarios"
SUPABASE_KEY = "sb_publishable_dYbXv-7LanEDcPT-MW7Xbg_rX71b6F3"

HEADERS = {
  "apikey" => SUPABASE_KEY,
  "Authorization" => "Bearer #{SUPABASE_KEY}",
  "Content-Type" => "application/json",
  "Prefer" => "return=representation"
}

headers = {
  "apikey" => SUPABASE_KEY,
  "Authorization" => "Bearer #{SUPABASE_KEY}",
  "Content-Type" => "application/json"
}

get '/' do
  redirect '/login'
end

get '/cadastro' do
  erb :cadastro
end

post '/cadastro' do
  usuario = params[:usuario]
  senha = params[:senha]

  if senha.length < 8
    @erro = "Mínimo 8 caracteres"
    return erb :cadastro
  elsif !senha.match(/[0-9]/)
    @erro = "Precisa ter 1 número"
    return erb :cadastro
  elsif !senha.match(/[A-Z]/)
    @erro = "Precisa ter 1 letra maiúscula"
    return erb :cadastro
  end

  senha_hash = BCrypt::Password.create(senha)

  HTTParty.post(
    SUPABASE_URL,
    headers: headers,
    body: {
      usuario: usuario,
      senha_hash: senha_hash
    }.to_json
  )

  redirect '/login'
end

get '/login' do
  erb :login
end

post '/login' do
  usuario = params[:usuario]
  senha = params[:senha]

  response = HTTParty.get(
    "#{SUPABASE_URL}?usuario=eq.#{usuario}",
    headers: headers
  )

  dados = JSON.parse(response.body)

  if dados.any? && BCrypt::Password.new(dados[0]["senha_hash"]) == senha
    erb :sucesso
  else
    @erro = "Login inválido"
    erb :login
  end
end