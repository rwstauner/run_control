if $0 == 'irb'

require "readline"

## always Always ALWAYS
IRB.conf[:USE_READLINE] = true

## irb history-saving extension
# require 'irb/ext/save-history'
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
IRB.conf[:SAVE_HISTORY] = 500

# Only for mac system irb.
$hist_loaded = ! $".detect { |l| l =~ %r{^/System/} }
def fixhist
  unless $hist_loaded
    loadhist
    $hist_loaded = true
  end
end

def loadhist
  STDERR.puts "loading hist"
  last = Readline::HISTORY.pop
  File.readlines(IRB.conf[:HISTORY_FILE]).each do |line|
    Readline::HISTORY << line.chomp
  end
  Readline::HISTORY << last unless last.nil?
end

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
	puts str
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

  def local_methods
    (self.methods - self.class.superclass.instance_methods).sort
  end

  def super_methods(m)
    supers = [m]
    while m = m.super_method
      supers << m
    end
    supers
  end
end

## built-in ri
def ri(what); quiet `ri "#{what}"`; end

## namespace
module Cantaloupe
	REASON = [	color(:bold, :magenta){%|"I'm scared."|},
				color(:bold, :green)  {%|"Tardy, you have a cantaloupe."|},
				color(:bold, :magenta){%|"Oh, I feel better, now."|}].join('  ')
end

if defined?(Readline) && Readline::HISTORY.to_a.empty?
  STDERR.puts "hit enter to fix hist" unless $hist_loaded
  # Tried overriding the string that gets put into the prompt
  # but that gets called too early.
  # self.define_singleton_method(:to_s) { do_stuff }
  IRB::ReadlineInputMethod.prepend(Module.new do
    def gets
      super.tap do
        fixhist
      end
    end
  end)
end

end
