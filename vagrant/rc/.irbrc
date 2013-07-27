IRB.conf[:USE_READLINE] = true
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
IRB.conf[:SAVE_HISTORY] = 500
require 'irb/completion'
IRB.conf[:EVAL_HISTORY] = 1000
