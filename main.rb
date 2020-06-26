# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "pg"

class Memo
  @@connect = PG.connect(dbname: "memo")

  def self.load
    @@connect.exec("SELECT * FROM Memos")
  end

  def self.add(post_text)
    title = Memo.title(post_text)
    body = Memo.body(post_text)
    @@connect.exec(
      "INSERT INTO Memos (title, body) VALUES ($1, $2)", [title, body]
    )
  end

  def self.destroy(id)
    @@connect.exec("DELETE FROM Memos WHERE id = $1", [id])
  end

  def self.find(id)
    @@connect.exec("SELECT * FROM Memos WHERE id = $1", [id]).first
  end

  def self.update(id, post_text)
    title = Memo.title(post_text)
    body = Memo.body(post_text)
    @@connect.exec(
      "UPDATE Memos SET title = $1, body = $2 WHERE id = $3", [title, body, id]
    )
  end

  def self.title(post_text)
    post_text.split("\s").first
  end

  def self.body(post_text)
    ary = post_text.split("\s")
    ary.delete_at(0)
    ary.join("\n")
  end
end

enable :method_override
get "/" do
  @items = Memo.load
  erb :index
end

get "/new_memo" do
  erb :form
end

post "/memos" do
  Memo.add(params[:text])
  redirect "/"
end

get "/:id" do |id|
  @item = Memo.find(id)
  erb :memo
end

delete "/:id" do |id|
  Memo.destroy(id)
  redirect "/"
end

get "/:id/edit" do |id|
  @item = Memo.find(id)
  erb :edit
end

patch "/:id/edit" do |id|
  Memo.update(id, params[:text])
  redirect "/"
end
