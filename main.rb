# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "pg"

class Memo
  attr_reader :connect

  DB_NAME = "memo"

  def initialize
    @connect = PG.connect(dbname: DB_NAME)
  end

  def self.load
    Memo.new.connect.exec("SELECT * FROM Memos")
  end

  def self.add(post_text)
    title = Memo.title(post_text)
    body = Memo.body(post_text)
    Memo.new.connect.exec(
      "INSERT INTO Memos (title, body) VALUES ('#{title}', '#{body}')"
    )
  end

  def self.destroy(id)
    Memo.new.connect.exec("DELETE FROM Memos WHERE id = #{id}")
  end

  def self.find(id)
    Memo.new.connect.exec("SELECT * FROM Memos WHERE id = #{id.to_i}").first
  end

  def self.update(id, post_text)
    title = Memo.title(post_text)
    body = Memo.body(post_text)
    Memo.new.connect.exec(
      "UPDATE Memos SET title = '#{title}', body = '#{body}' WHERE id = #{id}"
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
