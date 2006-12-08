require 'net/http'
require 'open-uri'
require 'hpricot'

class Campfire
  attr_accessor :subdomain, :host

  class Room
    attr_accessor :id
    
    def initialize(campfire, id)
      @campfire = campfire
      self.id = id
    end
    
    def toggle_guest_access
      post "room/#{self.id}/toggle_guest_access"
    end
    
    def guest_url
      (Hpricot(@campfire.send(:get, "room/#{self.id}").body)/"#guest_access h4").first.inner_html
    end
    
    def guest_invite_code
      guest_url.scan(/^#{@campfire.url}\/(\w*)$/).to_s
    end
    
    def rename(name)
      post "account/edit/room/#{self.id}", { :room => { :name => name }}, :ajax => true
    end
    
    def change_topic(topic)
      post "room/#{self.id}/change_topic", { 'room' => { 'topic' => topic }}, :ajax => true
    end
    
    def lock
      post "room/#{self.id}/lock", {}, :ajax => true
    end
    
    def unlock
      post "room/#{self.id}/unlock", {}, :ajax => true
    end
    
    def destroy
      post "account/delete/room/#{self.id}"
    end
    
    def speak(message, options = {})
      options = { :paste => false }.merge(options)
      post "room/#{self.id}/speak", { :message => message, :paste => options[:paste].inspect }, :ajax => true
    end
    
  private
  
    def post(path = nil, data = {}, options = {})
      @campfire.send :post, path, data, options
    end
    
  end
  
  def initialize(subdomain)
    self.subdomain = subdomain
    self.host = "#{subdomain}.campfirenow.com"
  end
  
  def login(email, password)
    @logged_in = verify_response(post("login", :email_address => email, :password => password), :redirect_to => url_for)
  end
  
  def create_room(name, topic = nil)
    find_room_by_name(name) if verify_response(post("account/create/room?from=lobby", {:room => {:name => name, :topic => topic}}, :ajax => true), :success)
  end
  
  def find_room_by_name(name)
    link = Hpricot(get.body).search("//h2/a").detect { |a| a.inner_html == name }
    link.blank? ? nil : Room.new(self, link.attributes['href'].scan(/room\/(\d*)$/).to_s)
  end

  
private

  def flatten(params)
    params = params.dup
    params.stringify_keys!.each do |k,v| 
      if v.is_a? Hash
        params.delete(k)
        v.each {|subk,v| params["#{k}[#{subk}]"] = v }
      end
    end
  end

  def url_for(path = "")
    "http://#{host}/#{path}"
  end
  

  def post(path, data = {}, options = {})
    @request = returning Net::HTTP::Post.new(url_for(path)) do |request|
      prepare_request(request, options)
      request.add_field 'Content-Type', 'application/x-www-form-urlencoded'
      request.set_form_data flatten(data)
    end
    returning @response = Net::HTTP.new(host, 80).start { |http| http.request(@request) } do |response|
      @cookie = response['set-cookie'] if response['set-cookie']
    end
  end
  
  def get(path = nil, options = {})
    @request = returning Net::HTTP::Get.new(url_for(path)) do |request|
      prepare_request(request, options)
    end
    returning @response = Net::HTTP.new(host, 80).start { |http| http.request(@request) } do |response|
      @cookie = response['set-cookie'] if response['set-cookie']
    end
  end
  
  def prepare_request(request, options = {})
    request.add_field 'Cookie', @cookie if @cookie
    if options[:ajax]
      request.add_field 'X-Requested-With', 'XMLHttpRequest'
      request.add_field 'X-Prototype-Version', '1.5.0_rc1'
    end
  end
  
  def verify_response(response, options = {})
    if options.is_a? Symbol
      response.code == case options
      when :success then "200"
      end
    elsif options[:redirect_to]
      response.code == "302" && response['location'] == options[:redirect_to]
    else
      false
    end
  end
  
end