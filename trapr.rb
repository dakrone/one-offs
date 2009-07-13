#!/usr/bin/env ruby

class Object
  def trapr_wrap(signal, newproc, function, *args)
    #puts "Trapping #{signal} with #{newproc.inspect}"
    oldproc = trap "#{signal}", newproc
    self.send("#{function}", *args)
  ensure
    #puts "Reseting trap. #{signal} -> #{oldproc.inspect}"
    trap "#{signal}", oldproc
  end
end

class Eggplant
  def initialize
  end
  
  def foo
    trap "SIGINT", Proc.new {
      puts "Trapped in foo!"
    }
    puts "I'm in foo for 5 seconds!"
    sleep(5);
    puts "Leaving foo."
  end

  def bar
    puts "I'm bar'n it up for 5 seconds!"
    sleep(5)
    puts "Done bar'n"
  end

end

trap "SIGINT", Proc.new { puts "Base trap." }
t = Eggplant.new
p = Proc.new { puts "Trapr'd!" }
# Trap bindings will be released when :foo exits
t.trapr_wrap "SIGINT", p, :foo
# Trap bindings will be released when :bar exits
t.trapr_wrap "SIGINT", p, :bar
puts "Back to base. T-minus 5."
sleep(5)


#  [1:hinmanm@Xanadu:~/src/ruby/trapr]% ./trapr.rb
#  I'm in foo for 5 seconds!
#  ^CTrapped in foo!
#  Leaving foo.
#  I'm bar'n it up for 5 seconds!
#  ^CTrapr'd!
#  Done bar'n
#  Back to base. T-minus 5.
#  ^CBase trap.

