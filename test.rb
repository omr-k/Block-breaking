require 'dxruby'

bar = Sprite.new(260,465,Image.new(100,10,C_WHITE))
bar_l = Sprite.new(260,465,Image.new(100,10,C_WHITE))
bar_r = Sprite.new(260,465,Image.new(100,10,C_WHITE))
bars = [bar,bar_r,bar_l]

walls = [Sprite.new(0,0,Image.new(5,480,C_WHITE)),
		 Sprite.new(0,0,Image.new(640,5,C_WHITE)),
		 Sprite.new(635,0,Image.new(5,480,C_WHITE))]
ball = Sprite.new(300,445,Image.new(20,20).circle_fill(10,10,10,C_RED))

se1 = Sound.new("resource/se1.wav")
se2 = Sound.new("resource/se2.wav")
bgm1 = Sound.new("resource/bgm1.wav")
bgm2 = Sound.new("resource/bgm2.wav")
bgm3 = Sound.new("resource/bgm3.wav")

def reset(n)
	@blocks = []
	case n
	when nil
		blocknum = rand(0..2)
	when 0
		blocknum = 0
	when 1
		blocknum = 1
	when 2
		blocknum = 2
	end
	case blocknum
	when 0
		5.times do |y|
			if y % 2 == 1
				10.times do |x|
					@blocks << Sprite.new(21+60*x,21+20*y,Image.new(58,18,[7,255,255]))
				end
			else
				10.times do |x|
					@blocks << Sprite.new(21+60*x,21+20*y,Image.new(58,18,[128,252,0]))
				end
			end
		end
	when 1
		num = 0
		5.times do |y|
			10.times do |x|
				if num % 2 == 1
					@blocks << Sprite.new(21+60*x,21+20*y,Image.new(58,18,[7,255,255]))
				else
					@blocks << Sprite.new(21+60*x,21+20*y,Image.new(58,18,[128,252,0]))
				end
				num += 1
			end
			num += 1
		end
	when 2
		9.times do |y|
			10.times do |x|
				case y
				when 0, 8
					if x != 1 && x != 8
						if x == 4 || x == 5
							@blocks << Sprite.new(21+60*x,21+19*y,Image.new(58,17,[128,252,0]))
						else
							@blocks << Sprite.new(21+60*x,21+19*y,Image.new(58,17,[7,255,255]))
						end
					end
				when 1, 7
					if x == 1 || x == 8
						@blocks << Sprite.new(21+60*x,21+19*y,Image.new(58,17,[128,252,0]))
					end
				when 2, 6
					if x != 1 && x != 8
						if x == 3 || x == 6
							@blocks << Sprite.new(21+60*x,21+19*y,Image.new(58,17,[128,252,0]))
						else
							@blocks << Sprite.new(21+60*x,21+19*y,Image.new(58,17,[7,255,255]))
						end
					end
				when 3, 5
					if x == 0 || x == 2 || x == 7 || x == 9
						@blocks << Sprite.new(21+60*x,21+19*y,Image.new(58,17,[128,252,0]))
					end
				when 4
					if x == 0 || x == 2 || x == 7 || x == 9
						@blocks << Sprite.new(21+60*x,21+19*y,Image.new(58,17,[7,255,255]))
					elsif x == 4 || x == 5
						@blocks << Sprite.new(21+60*x,21+19*y,Image.new(58,17,[128,252,0]))
					end
				end
			end
		end
	end
end

dx = 0
dy = 0
score = 0
startscore = 0
flag = 0
debugflag = 0
bgmflag = 1
count = 0
motion = 0

read = open("resource/highscore.rb","r")
highscore = read.gets.to_i

Window.loop do
	if flag == 0
		Window.draw_font_ex(220,300,"press ↓ to start",Font.new(32))
	elsif flag == 2
		Window.draw_font_ex(140,200,"GAME OVER",Font.new(64))
		Window.draw_font_ex(208,300,"press ↑ to start",Font.new(32))
	elsif flag == 3
		Window.draw_font_ex(16,200,"CONGRATULATIONS!",Font.new(64))
		Window.draw_font_ex(208,300,"press ↑ to start",Font.new(32))
	end
	Window.draw_font_ex(5,5,"SCORE:#{score}",Font.new(16))
	Window.draw_font_ex(260,5,"HIGHSCORE:#{highscore}",Font.new(16))
	Window.draw_font_ex(527,5,"push esc to end",Font.new(16))

	#debug
	if debugflag == 0 && Input.key_push?(K_RETURN)
		debugflag = 1
	elsif debugflag == 1 && Input.key_push?(K_RETURN)
		debugflag = 0
	end

	if debugflag == 1
		Window.draw_font_ex(5,428,"#{dx}",Font.new(16))
		Window.draw_font_ex(5,444,"#{dy}",Font.new(16))
		Window.draw_font_ex(600,428,"#{ball.x.round(1)}",Font.new(16))
		Window.draw_font_ex(600,444,"#{ball.y.round(1)}",Font.new(16))
	end

	#gamestart
	if Input.key_push?(K_DOWN) && flag == 0
		if Input.key_down?(K_1)
			reset(0)
		elsif Input.key_down?(K_2)
			reset(1)
		elsif Input.key_down?(K_3)
			reset(2)
		else
			reset(nil)
		end
		if motion != 3 && motion != 4
			dx = (4.0 + count*0.5)
			dy = -(4.0 + count*0.5)
		else
			dx = -(4.0 + count*0.5)
			dy = -(4.0 + count*0.5)
		end
		flag = 1
	end

	Sprite.draw(walls)
	Sprite.draw(bars)
	ball.draw
	Sprite.draw(@blocks)

	#bar
	case motion
	when 0
		bx = 0
	when 1
		bx = 5
	when 2
		bx = 9
	when 3
		bx = -5
	when 4
		bx = -9
	end

	if Input.key_push?(K_UP)
		motion = 0
	elsif Input.key_push?(K_RIGHT)
		if motion == 1 || motion == 2
			motion = 2
		else
			motion = 1
		end
	elsif Input.key_push?(K_LEFT)
		if motion == 3 || motion == 4
			motion = 4
		else
			motion = 3
		end
	end

	if bar.x < -35
		bar.x = 593.9
	end

	if bar.x > 595
		bar.x = -36.1
	end

	bar.x += bx
	bar_r.x = bar.x + 630
	bar_l.x = bar.x - 630

	#ball
	if flag == 0
		if bar.x + 40 < 5
			ball.x = 5
		elsif bar.x + 40 > 615
			ball.x = 615
		else
			ball.x = bar.x + 40
		end
		ball.y = bar.y - 25
	end

	ball.x += dx
	if ball === walls
		ball.x -= dx
		dx = -dx
		se2.play
	end

	col_x = ball.check(@blocks).first
	if col_x
		# p "#{col_x.x}, #{col_x.y}"
		col_x.vanish
		dx = dx
		dy = dy
		ball.x -= dx
		dx = -dx
		score += 100
		se1.play
	end

	ball.y += dy
	if ball === walls
		ball.y -= dy
		dy = -dy
		se2.play
	end

	col_y = ball.check(@blocks).first
	if col_y
		# p "#{col_y.x}, #{col_y.y}"
		col_y.vanish
		dx = dx
		ball.y -= dy
		dy = -dy
		score += 100
		se1.play
	end

	if ball === bars && ball.y < 465
		if dx > 0
			if motion == 1 || motion == 2
				dx = dx * 1.1
			elsif motion == 3 || motion == 4
				dx = dx / 1.1
			else
				dx = dx
			end
		elsif dx < 0
			if motion == 1 || motion == 2
				dx = dx / 1.1
			elsif motion == 3 || motion == 4
				dx = dx * 1.1
			else
				dx = dx
			end
		end
		dy = dy.abs * -1
		if dx.abs < 2
			if dx < 0
				dx = -2
			else
				dx = 2
			end
		end
		se2.play
	end

	#gameover
	if ball.y > 480
		ball.y = 480
		dx = 0
		dy = 0
		if score > highscore
			highscore = score
			rewrite = open("resource/highscore.rb","w+")
			rewrite.write("#{score}")
		end
		count = 0
		startscore = 0
		flag = 2
		bgmflag = 2
	end

	#stage_clear
	if score % 5000 == 0 && flag != 3 && score != startscore
		dx = 0
		dy = 0
		startscore = score
		count += 1
		flag = 3
		bgmflag = 3
	end

	#retry
	if Input.key_push?(K_UP) && (flag == 2 || flag == 3)
		if flag == 2
			score = 0
		end
		flag = 0
		bgmflag = 1
	end

	#bgm
	case bgmflag
	when 1
		bgm1.stop
		bgm2.stop
		bgm3.stop
		bgm1.loop_count = (-1)
		bgm1.play
		bgmflag = 0
	when 2
		bgm1.stop
		bgm2.loop_count = (-1)
		bgm2.play
		bgmflag = 0
	when 3
		bgm1.stop
		bgm3.play
		bgmflag = 0
	end

	#highscore_reset
	if (Input.key_down?(K_SPACE) && Input.key_push?(K_LCONTROL)) || (Input.key_down?(K_LCONTROL) && Input.key_push?(K_SPACE))
		highscore = 0
		score_reset = open("resource/highscore.rb","w+")
		score_reset.write("0")
	end

	break if Input.key_push?(K_ESCAPE)
end