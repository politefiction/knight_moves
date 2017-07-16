class Square
	attr_accessor :coord
	def initialize (coord)
		@coord = coord
	end
end

# Keeps track of possible moves for the knight (can do so for other chess pieces, presumably)
class MoveSet
	attr_accessor :from, :to, :previous
	def initialize(from, to=[], previous=nil)
		@from = from
		@to = to
	end
end

class ChessBoard
	@@board = []
	x = 0
	y = (0..7).to_a
	while x < 8
		y.each { |coord| @@board << Square.new([x, coord]) }
		x += 1
	end

	def self.board
		@@board
	end

end

class Knight < ChessBoard
	@@moves = []

	def initialize ()
		calculate_moves(1, 2)
	end

	def calculate_moves(a, b)
		@@board.each do |square| 
			x = square.coord[0]
			y = square.coord[1]
			current_square = MoveSet.new(square)
			@@board.each { |squ| current_square.to << squ if squ.coord == [x + a, y + b] || squ.coord == [x + a, y - b] || squ.coord == [x - a, y - b] || squ.coord == [x - a, y + b] }
			@@board.each { |squ| current_square.to << squ if squ.coord == [x + b, y + a] || squ.coord == [x + b, y - a] || squ.coord == [x - b, y - a] || squ.coord == [x - b, y + a] }
			@@moves << current_square
		end
	end

	def self.moves
		@@moves
	end

	# Created for investigative purposes
	def self.find_moves_for(coord)
		starting_square = @@moves.select { |set| set.from.coord == coord }[0]
		starting_square.to.each { |square| puts square.coord.inspect }
	end

	
	@@searched = []
	@@path = []
	@@queue = []

	# Made it a class method since all knights have the same range of movement
	def self.shortest_path(a, b, root=nil)
		start = @@moves.select { |set| set.from == a or set.from.coord == a }[0]
		target = @@board.select { |square| square.coord == b }[0]
		root ||= start
		root.previous = nil
		@@searched << start.from unless @@searched.include? start.from
		@@queue.shift unless @@queue.empty?
		if start.to.include? target
			path = []
			path << start.from.coord
			path << b
			current_set = start
			while current_set.previous!=nil
				path.unshift(current_set.previous.from.coord) 
				current_set = current_set.previous
			end
			@@path = path if @@path.empty? or path.length < @@path.length
		else
			start.to.each { |square| @@queue << square } if start == root
			start.to.each do |square|
				next_move = @@moves.select { |set| set.from == square }[0]
				@@searched << next_move.from unless @@searched.include? next_move.from
				next_move.previous ||= start
				next_move.to.each do |sq| 
					@@moves.select { |set| set.from == sq }[0].previous ||= next_move
					@@queue << sq unless sq == start.from or @@queue.include? sq or @@searched.include? sq
				end

			end

			self.shortest_path(@@queue[0], b, root) unless @@queue.empty?
		end
		"Shortest path between #{a} and #{b} is #{@@path.length-1} moves: 
		#{@@path.inspect}"
	end

end

board1 = ChessBoard.new
knight1 = Knight.new
puts Knight.shortest_path([5, 6], [2, 5])
