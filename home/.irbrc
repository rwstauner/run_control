if $0 == 'irb'

## always Always ALWAYS
IRB.conf[:USE_READLINE] = true

## irb history-saving extension
#require 'irb/ext/save-history'
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
IRB.conf[:SAVE_HISTORY] = 500
	## not necessary
	#class IRB::Irb
	#	alias_method :non_historical_initialize, :initialize
	#	def initialize(*args)
	#		non_historical_initialize(*args)
	#		@context.history_file = "#{ENV['HOME']}/.irb_history"
	#		@context.save_history = 500
	#		#@context.io.load_history ## don't need to call this explicitly
	#	end
	#end

module Cantaloupe
	COLOR = {
		:blue 		=> 34,
		:bold 		=>  5,
		:cyan 		=> 36,
		:green 		=> 32,
		:grey 		=> 37,
		:magenta 	=> 35,
		:off 		=>  0,
		:orange 	=> 33,
		:red 		=> 31,
		:return 	=> 36
	}
	def Cantaloupe.color(*which)
		which = [:off] if which.empty?
		esc = "\033[" + which.map{|w| COLOR[w].to_s }.join(';') + "m"
		esc += yield().to_s + color(:off) if block_given? ## who doesn't love recursion?
		return esc
	end
end

## leave my prompt alone!
at_exit { puts Cantaloupe.color(:red){' good riddance!'} rescue nil } ## hey, that's not nice.

## get method tab-completion like script/console
require 'irb/completion'

## save last result in _ variable
IRB.conf[:EVAL_HISTORY] = 1000

## prompt decoration (of course)
## %M causes script/console to hang (lots of stuff)
prog = ( (ENV['RAILS_ENV'] || ENV['RAILS_PROJECT']) && ENV['PWD'].match(/\/www\/rails\/([^\/]+)/) ? $1 : '%N')
if IRB.conf[:PROMPT]
	IRB.conf[:PROMPT][:WOUNDED] = {
		#:PROMPT_I => "%[\033[35m%]%N%[\033[0m%]/%m:%03n:%i:> ",
		:PROMPT_I => "#{prog} /%m:%03n:%i:> ",
		:PROMPT_C => "#{prog} /%m:%03n:%i\\  ",
		:PROMPT_S => "#{prog} /%m:%03n:%i%l  ",
		:RETURN   => " \033[35m=> #{Cantaloupe.color(:return)}%s#{Cantaloupe.color(:off)}\n"
	}
	IRB.conf[:PROMPT_MODE] = :WOUNDED
end

def quiet(str)
	#loud = conf.return_format
	#conf.return_format = nil
	puts str
	#conf.return_format = loud
	nil
end

class Object
	def methods_irb(re=nil, others=nil)
		meths = (others || methods).sort.inspect
		meths.gsub!(re, "#{Cantaloupe.color(:bold, :blue)}\\&#{Cantaloupe.color(:off, :return)}") if re
		quiet IRB.conf[:PROMPT][:WOUNDED][:RETURN] % meths
	end
	def methods_local(re=nil)
		methods_irb(re, self.methods - self.class.superclass.instance_methods)
	end
end

## built-in ri
def ri(what); quiet `ri "#{what}"`; end

#require 'strscan'

#require 'rubygems'
#require_gem 'rails'
#$:.push(*%w|/www/rails/lib /www/rails|)

## namespace
module Cantaloupe
class <<self
	def irb_msg(msg)
		#warn " \033[37m::\033[33m " + msg.to_s + " \033[37m::\033[0m "
		warn [color(:grey), '::', color(:orange){ msg }, color(:grey){ '::' }].join(' ')
	end
end
	REASON = [	color(:bold, :magenta){%|"I'm scared."|},
				color(:bold, :green)  {%|"Tardy, you have a cantaloupe."|},
				color(:bold, :magenta){%|"Oh, I feel better, now."|}].join('  ')
end

## reminder
puts Cantaloupe::REASON
Cantaloupe.irb_msg Cantaloupe.singleton_methods.sort.join(' ')

end
