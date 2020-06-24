require 'byebug'
class Maze
    attr_reader :maze, :current_space, :closed_list, :parent_hash, :spaces, :done ###might want to delete from this later for security
    
    def initialize(maze_name)
        f = File.open(maze_name)
        @maze = f.readlines
        row_length = @maze[0].length - 1 
        col_length = @maze.length 
        @spaces = Array.new(col_length, "_") {Array.new(row_length, "_")} 
        @closed_list = []
        @parent_hash = Hash.new()
        @end_adj_hash = Hash.new()
        @done = false
    end

    ###################################

    def run ###def not sure about this one
        self.fill_spaces
        self.start_pos
        self.end_pos
        while !@done
            self.make_move
        end
        self.finished
    end

    def make_move
        self.current_space
        self.parent_hash 
        self.next_space
    end
    
    def finished
        puts "THE MAZE IS COMPLETE"
        @spaces
    end

    ######################################

    def fill_spaces #gives me the grid with all unavailable spots fill in with $
        (0...@spaces.length).each do |row|
            (0...@spaces[row].length).each do |col|
               @spaces[row][col] = "S" if @maze[row][col] == "S"
               @spaces[row][col] = "E" if @maze[row][col] == "E"
               @spaces[row][col] = "$" if @maze[row][col] != " " && @spaces[row][col] == "_"
            end
        end
        @spaces
    end

    def start_pos #remember this return a [] pos, would like to find out something at automatically converts pos to @spaces[row][col]
        row = @spaces.detect {|array| array.include?("S")}
        @closed_list << [@spaces.index(row), row.index("S")]
        return [@spaces.index(row), row.index("S")]
    end

    def end_pos
        row = @spaces.detect {|array| array.include?("E")}
        return [@spaces.index(row), row.index("E")]
    end

    def adj_end?(next_space)
        false if next_space == nil
        row, col = next_space[0], next_space[1]
        ((row - 1)..(row + 1)).each do |x|
            ((col - 1)..(col + 1)).each do |y|
                pos = [x, y]
                return true if @spaces[x][y] == "E"
                #return self.finished if @spaces[x][y] == "E"
            end
        end 
        false 
    end

    #########################  Helpers: ##############################

    def current_space #need to add an else here for cases after the first, will need to call on last move
        @closed_list.last
    end

    def walkable?(pos)#might be able to clean this up with a bracket method or something but unsure
        row, col = pos[0], pos[1]
        return true if @spaces[row][col] == "_"
        false
    end

    def [](pos)#gives what is in the grid at the give position
        row = pos[0]
        col = pos[1]
        @spaces[row][col]
    end

    def parent_hash 
        @current_space = self.current_space
        #return self.finished if self.adj_end?
        row, col = @current_space[0], @current_space[1]
        ((row - 1)..(row + 1)).each do |x|
            ((col - 1)..(col + 1)).each do |y|
                pos = [x, y]
                @parent_hash[pos] = @current_space if self.walkable?(pos) && !@closed_list.include?(pos)
            end
        end 
        @parent_hash
    end

    def g_cost(pos) #finds movement cost from starting pos, might have to add parent square g-cost sometime
        row, col = pos[0], pos[1]
        parent = @parent_hash[pos] #if i can incorporate the parent_hash method into another method might be able to siplify
        return 14 if parent[1] != col && parent[0] != row #cost of diagonal movement
        return 10 
    end

    def h_cost(pos)#estimates the total amount of movement to final destination vert. and hor. w/out barriers * 10
        cost = 0
        row, col = pos[0], pos[1]
        e_row, e_col = self.end_pos[0], self.end_pos[1]
        cost += e_col - col 
        return cost * 10 if row == e_row 
        cost += e_row - row 
        return cost * 10
    end

    def f_cost(gcost, hcost)
        return gcost + hcost
    end

    def next_space#parent hash/open list must be called before this
        f_score = {}

        @parent_hash.each_key do |adj_space|
             if @parent_hash[adj_space] == @current_space
                 f_cost = self.f_cost(g_cost(adj_space), h_cost(adj_space))
                 f_score[adj_space] = f_cost
             end
        end

        f_score.sort_by {|k, v| v}
        next_space = f_score.keys.last
        @closed_list << next_space
        @done = true if self.adj_end?(next_space)
        #debugger if next_space == nil 
        row = next_space[0]
        col = next_space[1]
        #@parent_hash.delete(next_space)
        @spaces[row][col] = "X"
        next_space
    end

end