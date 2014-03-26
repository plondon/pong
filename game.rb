require 'rubygems'
require 'rubygame'
 
class Game
    def initialize
        @screen = Rubygame::Screen.new [640, 480], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
        @screen.title = "Pong"
 		@background = Background.new @screen.width, @screen.height
        @queue = Rubygame::EventQueue.new
        @clock = Rubygame::Clock.new
        @clock.target_framerate = 60
        limit = @screen.height - 10
        @player = Paddle.new 50, 10, Rubygame::K_W, Rubygame::K_S, 10, limit
        @enemy = Paddle.new @screen.width-50-@player.width, 10, Rubygame::K_UP, Rubygame::K_DOWN, 10, limit
        @player.center_y @screen.height
        @enemy.center_y @screen.height
        @ball = Ball.new @screen.width/2, @screen.height/2
        @background = Background.new @screen.width, @screen.height
    end
 
    def run!
        loop do
            update
            draw
            @clock.tick
        end
    end
 
    def update
    	@player.update
    	@enemy.update
    	@ball.update @screen
        @queue.each do |ev|
        	@player.handle_event ev
        	@enemy.handle_event ev
            case ev
                when Rubygame::QuitEvent
                    Rubygame.quit
                    exit
                when Rubygame::KeyDownEvent
                	if ev.key == Rubygame::K_ESCAPE
                		@queue.push Rubygame::QuitEvent.new
                	end
            end
        end
        if collision? @ball, @player
        	@ball.collision @player, @screen
        elsif collision? @ball, @enemy
        	@ball.collision @enemy, @screen
        end
    end
 
    def draw
    	@screen.fill [0,0,0]
    	@background.draw @screen
    	@player.draw @screen
    	@enemy.draw @screen
    	@ball.draw @screen
    	@screen.flip
    end

    def collision? obj1, obj2
    	if obj1.y + obj1.height < obj2.y ; return false ; end
    	if obj1.y > obj2.y + obj2.height ; return false ; end
    	if obj1.x + obj1.width < obj2.x ; return false ; end
    	if obj1.x > obj2.x + obj2.width ; return false ; end
    	return true
    end
end

class GameObject
	attr_accessor :x, :y, :width, :height, :surface

	def initialize x, y, surface
		@x = x
		@y = y
		@surface = surface
		@width = surface.width
		@height = surface.height
	end

	def update
	end

	def draw screen
		@surface.blit screen, [@x, @y]
	end

	def handle_event event
	end
end

class Background < GameObject
	def initialize width, height
		surface = Rubygame::Surface.new [width, height]

		white = [255,255,255]

		surface.draw_box_s [0,0], [surface.width, 10], white

		surface.draw_box_s [0,0], [10, surface.height], white

		surface.draw_box_s [0, surface.height-10], [surface.width, surface.height], white

		surface.draw_box_s [surface.width-10, 0], [surface.width, surface.height], white

		surface.draw_box_s [surface.width/2-5, 0], [surface.width/2+5, surface.height], white

		super 0, 0, surface
	end
end

class Paddle < GameObject
	def initialize x,y,up_key, down_key, top_limit, bottom_limit
		surface = Rubygame::Surface.new [20,100]
		surface.fill [255,255,255]
		@up_key = up_key
		@down_key = down_key
		@moving_up = false
		@moving_down = false
		@top_limit = top_limit
		@bottom_limit = bottom_limit
		super x, y, surface
	end

	def center_y h
		@y = h/2-@height/2
	end

	def handle_event event
		case event
		when Rubygame::KeyDownEvent
			if event.key == @up_key
				@moving_up = true
			elsif event.key == @down_key
				@moving_down = true
			end
		when Rubygame::KeyUpEvent
			if event.key == @up_key
				@moving_up = false
			elsif event.key == @down_key
				@moving_down = false
			end
		end
	end

	def update
		if @moving_up && @y > @top_limit
			@y -= 5
		end
		if @moving_down && @y+@height < @bottom_limit
			@y += 5
		end
	end
end

class Ball < GameObject
	def initialize x,y
		surface = Rubygame::Surface.load "ball.png"
		@vx = @vy = 5
		super x,y,surface
	end

	def update screen
		@x += @vx
		@y += @vy

		if @x <= 10 or @x+@width >= screen.width - 10
			@vx *= -1
		end

		if @y <= 10 or @y+@height >= screen.height - 10
			@vy *= -1
		end
	end

	def collision paddle, screen
		if paddle.x < screen.width/2
			unless @x < paddle.x-5
				@x = paddle.x + paddle.width+1
				@vx *= -1
			end
		else
			unless @x > paddle.x+5
				@x = paddle.x-@width-1
				@vx *= -1
			end
		end
	end
end
 
g = Game.new
g.run!