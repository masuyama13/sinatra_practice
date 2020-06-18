# frozen_string_literal: true

require "sinatra"
require "sinatra/reloader"
require "json"

class Memo
  attr_reader :id, :title, :body

  FILE_NAME = "memos.json"

  def initialize(id, title, body)
    @id = id
    @title = title
    @body = body
  end

  def self.load
    File.open(FILE_NAME) { |f| JSON.load(f) }
  end

  def self.create(post_data)
    id = Memo.load.size == 0 ? 1 : Memo.load[-1]["id"] + 1
    title = Memo.title(post_data)
    body = Memo.body(post_data)
    Memo.new(id, title, body)
  end

  def self.add(post_data)
    new_memos = Memo.load << Memo.create(post_data).to_hash
    File.open(FILE_NAME, "w") { |f| JSON.dump(new_memos, f) }
  end

  def self.destroy(id)
    new_memos = Memo.load.delete_if { |item| item["id"] == id.to_i }
    File.open(FILE_NAME, "w") { |f| JSON.dump(new_memos, f) }
  end

  def self.create_with_id(id, post_data)
    title = Memo.title(post_data)
    body = Memo.body(post_data)
    Memo.new(id, title, body)
  end

  def self.refer(item)
    id = item["id"]
    title = item["title"]
    body = item["body"]
    Memo.new(id, title, body)
  end

  def self.find(id)
    File.open(FILE_NAME) do |f|
      target_item = Memo.load.find { |item| item["id"] == id.to_i }
      Memo.refer(target_item)
    end
  end

  def self.update(id, text)
    memos = Memo.load
    memos[Memo.find_index(id)] = Memo.create_with_id(id.to_i, text).to_hash
    File.open(FILE_NAME, "w") { |f| JSON.dump(memos, f) }
  end

  def self.find_index(id)
    Memo.load.find_index { |item| item["id"] == id.to_i }
  end

  def self.title(post_data)
    post_data.split("\s")[0]
  end

  def self.body(post_data)
    ary = post_data.split("\s")
    ary.delete_at(0)
    ary.join("<br>")
  end

  def to_hash
    { "id" => id, "title" => title, "body" => body }
  end

  def text_show
    title + "\n" + "\n" + body.gsub("<br>", "\n")
  end
end

enable :method_override
get "/" do
  @hash_data = Memo.load
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
  @item = Memo.find(id).to_hash
  erb :memo
end

delete "/:id" do |id|
  Memo.destroy(id)
  redirect "/"
end

get "/:id/edit" do |id|
  @former_text = Memo.find(id).text_show
  erb :edit
end

patch "/:id/edit" do |id|
  Memo.update(id, params[:text])
  redirect "/"
end
