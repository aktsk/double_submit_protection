# Double Submit Protection Plugin

This plugin implements a symetrical token approach to avoid duplicate posts of data. This is specially
useful when you're dealing with data-sensitive forms (credit-card processing, for instance), where
a duplicated posting may lead to a user getting charged twice. This control is done via a
token placed on user's form and synchronized with the session - whenever the token is different, you
can simply verify it on the controllers by using the 'double_submit?' method

# Usage Example

## some_view.html.erb

~~~
<%= form_for :blah, :url => { :action => "create" } do |f| %>
  ... (some form content here)
  <%= double_submit_token %>
<% end %>

<%= form_for :foo, :url => { :action => "create" } do |f| %>
  ... (some form content here)
  <%= double_submit_token 'foo_submit_token' %>
<% end %>
~~~

## blah_controller.rb

~~~
def create
  if double_submit?
    flash[:message] = 'Whoa, hang in there dude...'
    render :action => :register
    return
  end

  # do something here
end
~~~

## foo_controller.rb

~~~
def create
  if double_submit? 'foo_submit_token'
    flash[:message] = 'Whoa, hang in there dude...'
    render :action => :register
    return
  end

  # do something here
end
~~~
