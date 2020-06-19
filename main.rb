# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "pg"

module Memo
  def self.load
    connect = PG.connect(dbname: "memo")
    items = connect.exec("SELECT * FROM Memos")
    connect.finish
    items
  end

  def self.add(post_text)
    connect = PG.connect(dbname: "memo")
    connect.exec("INSERT INTO Memos (title, body) VALUES (\'#{Memo.title(post_text)}\', \'#{Memo.body(post_text)}\')")
    connect.finish
  end

  def self.destroy(id)
    connect = PG.connect(dbname: "memo")
    connect.exec("DELETE FROM Memos WHERE id = #{id}")
    connect.finish
  end

  def self.find(id)
    connect = PG.connect(dbname: "memo")
    item = connect.exec("SELECT * FROM Memos WHERE id = #{id.to_i}")
    connect.finish
    item[0]
  end

  def self.edit_text(id)
    target = Memo.find(id)
    target["title"] + "\n" + "\n" + target["body"].gsub("<br>", "\n")
  end

  def self.update(id, post_text)
    connect = PG.connect(dbname: "memo")
    connect.exec("UPDATE Memos SET title = \'#{Memo.title(post_text)}\', body = \'#{Memo.body(post_text)}\' WHERE id = #{id}")
    connect.finish
  end

  def self.title(post_text)
    post_text.split("\s")[0]
  end

  def self.body(post_text)
    ary = post_text.split("\s")
    ary.delete_at(0)
    ary.join("<br>")
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
  @item = Memo.edit_text(id)
  erb :edit
end

patch "/:id/edit" do |id|
  Memo.update(id, params[:text])
  redirect "/"
end
