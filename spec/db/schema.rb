ActiveRecord::Schema.define(:version => 0) do
  create_table :people, :force => true do |t|
    t.column :name, :string
    t.column :type, :string
    t.column :password, :string
  end
  
  create_table :posts, :force => true do |t|
    t.column :title, :string
    t.column :body, :text
  end
  
  create_table :comments, :force => true do |t|
    t.column :post_id, :integer
    t.column :author, :string
    t.column :body, :text
  end
end
