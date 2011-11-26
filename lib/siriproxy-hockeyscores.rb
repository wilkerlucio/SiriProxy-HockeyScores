require 'cora'
require 'siri_objects'
require 'open-uri'
require 'nokogiri'

#############
# This is a plugin for SiriProxy that will allow you to check tonight's hockey scores
# Example usage: "What's the score of the Avalanche game?"
#############

class SiriProxy::Plugin::HockeyScores < SiriProxy::Plugin

  @firstTeamName = ""
  @firstTeamScore = ""
  @secondTeamName = ""
  @secondTeamScore = ""
	
	def initialize(config)
    #if you have custom configuration options, process them here!
  end
  
  listen_for /score of the (.*) game/i do |phrase|
	  team = pickOutTeam(phrase)
	  score(team) #in the function, request_completed will be called when the thread is finished
	end
	
	listen_for /hello bob /i do
	  say "Siri Proxy is up and running!" #say something to the user!
    
    request_completed #always complete your request! Otherwise the phone will "spin" at the user!
  end
	
	def score(userTeam)
	  Thread.new {
	    doc = Nokogiri::HTML(open("http://www.nhl.com/ice/m_scores.htm"))
      scores = doc.css(".gmDisplay")
      
      scores.each {
        |score|
        team = score.css(".blkcolor")
        team.each {
          |teamname|
          if(teamname.content.strip.downcase == userTeam.downcase)
            firstTeam = score.css("tr:nth-child(2)").first
            @firstTeamName = firstTeam.css(".blkcolor").first.content.strip
            @firstTeamScore = firstTeam.css("td:nth-child(2)").first.content.strip
            secondTeam = score.css("tr:nth-child(3)").first
            @secondTeamName = secondTeam.css(".blkcolor").first.content.strip
            @secondTeamScore = secondTeam.css("td:nth-child(2)").first.content.strip
            break
          end
        }
      }
      if((@firstTeamName == "") || (@secondTeamName == ""))
        response = "No games involving the " + userTeam + " were found playing tonight"
      else 
        response = "The score for the " + userTeam + " game is: " + @firstTeamName + " (" + @firstTeamScore + "), " + @secondTeamName + " (" + @secondTeamScore + ")"
			end  
			@firstTeamName = ""
			@secondTeamName = ""
			say response
			
			request_completed
		}
		
	  say "Checking on tonight's hockey games"
	end
	
  def pickOutTeam(phrase)
    if(phrase.match(/anaheim/i)) 
      return "Ducks"
    end
    if(phrase.match(/boston/i))
      return "Bruins"
    end
    if(phrase.match(/buffalo/i))
      return "Sabres"
    end
    if(phrase.match(/calgary/i))
      return "Flames"
    end
    if(phrase.match(/carolina/i) || phrase.match(/canes/i))
      return "Hurricanes"
    end
    if(phrase.match(/chicago/i) || phrase.match(/hawks/i))
      return "Blackhawks"
    end
    if(phrase.match(/colorado/i) || phrase.match(/aves/i))
      return "Avalanche"
    end
    if(phrase.match(/columbus/i) || phrase.match(/jackets/i))
      return "Blue Jackets"
    end
    if(phrase.match(/dallas/i))
      return "Stars"
    end
    if(phrase.match(/detroit/i))
      return "Red Wings"
    end
    if(phrase.match(/edmonton/i))
      return "Oilers"
    end
    if(phrase.match(/florida/i))
      return "Panthers"
    end
    if(phrase.match(/L.A/i) || phrase.match(/angeles/i))
      return "Kings"
    end
    if(phrase.match(/minnesota/i) || phrase.match(/minny/i))
      return "Wild"
    end
    if(phrase.match(/montr.*al/i) || phrase.match(/canadi.*ns/i) || phrase.match(/habs/i))
      return "Canadiens"
    end
    if(phrase.match(/nashville/i) || phrase.match(/preds/i))
      return "Predators"
    end
    if(phrase.match(/jersey/i))
      return "Devils"
    end
    if(phrase.match(/islanders/i))
      return "Islanders"
    end
    if(phrase.match(/rangers/i))
      return "Rangers"
    end
    if(phrase.match(/ottawa/i) || phrase.match(/sens/i))
      return "Senators"
    end
    if(phrase.match(/philadelphia/i) || phrase.match(/philly/i) || phrase.match(/fliers/i))
      return "Flyers"
    end
    if(phrase.match(/phoenix/i) || phrase.match(/yotes/i))
      return "Coyotes"
    end
    if(phrase.match(/pittsburgh/i) || phrase.match(/pens/i))
      return "Penguins"
    end
    if(phrase.match(/san/i) || phrase.match(/jose/i))
      return "Sharks"
    end
    if(phrase.match(/louis/i) || phrase.match(/saint/i))
      return "Blues"
    end
    if(phrase.match(/tampa/i) || phrase.match(/bay/i))
      return "Lightning"
    end
    if(phrase.match(/toronto/i) || phrase.match(/leafs/i))  
      return "Maple Leafs"
    end
    if(phrase.match(/vancouver/i) || phrase.match(/nucks/i))
      return "Canucks"
    end
    if(phrase.match(/washington/i) || phrase.match(/caps/i))
      return "Capitals"
    end
    if(phrase.match(/winnipeg/i))
      return "Jets"
    end
	  
	  # The above should catch city names, team nicknames, or words which Siri would misinterpret
	  # If the person said the team name verbatim as NHL needs just return it
    
    return phrase
    
	end
end