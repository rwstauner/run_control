# rubocop:disable all
Pry.config.pager = false

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
