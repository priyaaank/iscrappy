require 'mechanize'

class Proxy

  def initialize()
    #@agent_pool = define_agents_for(['183.232.25.45', '119.97.151.160', '183.232.25.44', '119.97.151.157'])
    @agent_pool = define_agents_for(['183.232.25.45', '183.232.25.44', '119.97.151.157'])
    #@agent_pool = define_agents_for(['183.232.25.45','85.185.45.241'])
  end

  def page_with_proxy(pageURL)
    agent = @agent_pool.sample
    puts "Using agent #{agent} to fetch request"
    begin
    agent.get(pageURL)
    rescue StandardError => e
      puts "*"*100
      puts "Exception occured #{e}"
      puts "*"*100
      page_with_proxy(pageURL)
    end
  end

  private

  def define_agents_for ip_addresses
    ip_addresses.collect do |ip_address|
      agent = Mechanize.new {|a| a.user_agent_alias = 'Mac Safari' }
      agent.set_proxy(ip_address, 80)
      puts "Agent #{agent} assigned with proxy #{ip_address}"
      agent
    end
  end
end
