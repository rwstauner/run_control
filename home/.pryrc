# frozen_string_literal: true

# begin
#   require 'rb-readline'
# rescue LoadError
#   nil
# end

# rubocop:disable all
Pry.config.pager = false
Pry.config.hooks.add_hook :before_eval, "-pry-time-before-", ->(_, pry) {
  $_pry_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
}
Pry.config.hooks.add_hook :after_eval, "-pry-time-after-", ->(_, pry) {
  (Process.clock_gettime(Process::CLOCK_MONOTONIC) - $_pry_time).tap { |s|
    pry.config.prompt_name = sprintf("%.3fs ", s)
  }
}

# Call (from .pryrc_local) if rb-readline is in use.
def fix_rb_readline
  # Ignore ~/.inputrc
  ENV['INPUTRC'] = '/dev/null'

  RbReadline.instance_eval do
    rl_bind_keyseq_if_unbound("\033[1;5D", :rl_backward_word)
    rl_bind_keyseq_if_unbound("\033[1;5C", :rl_forward_word)
  end
end

class Object
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
