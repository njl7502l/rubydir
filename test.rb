require 'curses'

class << mwin = Curses.init_screen
  def myInit
    box('|', '-', '+')

    Curses.start_color
    Curses.init_pair(1, Curses::COLOR_RED, Curses::COLOR_BLACK)
    Curses.init_pair(2, Curses::COLOR_GREEN, Curses::COLOR_BLACK)
  end
end
mwin.myInit

body_size = { y: Curses.lines - 6, x: Curses.cols }
body_origin = { y: 3, x: 0 }
body_center = { y: body_size[:y] / 2 + body_origin[:y],
                x: body_size[:x] / 2 + body_origin[:x] }
graph_size = {
  x: if (body_size[:y] * 2) > body_size[:x]
       body_size[:x]
     else
       body_size[:y] * 2
     end
}
graph_size.merge!(y: graph_size[:x] / 2)
graph_origin = {
  x: body_center[:x] - (graph_size[:x] / 2),
  y: body_center[:y] - (graph_size[:y] / 2)
}

class << header = mwin.subwin(3, Curses.cols, 0, 0)
  def myInit
    box('|', '-', '+')
  end

  def show_str(str)
    setpos(1, Curses.cols / 2 - (str.length / 2))
    addstr(str)
  end
end

class << footer = mwin.subwin(3, Curses.cols, Curses.lines - 3, 0)
  def myInit
    box('|', '-', '+')
  end

  def show_str(str)
    setpos(1, Curses.cols / 2 - (str.length / 2))
    addstr(str)
  end
end

class << graph = mwin.subwin(graph_size[:y], graph_size[:x], graph_origin[:y], graph_origin[:x])
  def myInit
    box('|', '-', '+')
    setpos(1, 1)
    attron(Curses.color_pair(1))
    attron(Curses::A_BOLD)
    addstr('+')
    attroff(Curses::A_BOLD)
    attroff(Curses.color_pair(1))
  end

  def addPoint(x, y, distance)
    px = constrain_point(x, 1, maxx - 2)
    py = constrain_point(y, 1, maxy - 2)

    setpos(py, px)

    attron(get_color(distance))
    addstr('.')
    attroff(get_color(distance))
  end

  private

  def get_color(distance)
    if 1 >= distance
      Curses.color_pair(2)
    else
      Curses.color_pair(1)
    end
  end

  def constrain_point(val, min, max)
    if val <= min
      min
    elsif val >= max
      max
    else
      val
    end
  end
end

def get_try_times
  prompt_message = 'try times: '

  dialog = Curses::Window.new(
    3, prompt_message.length + 10,
    (Curses.lines - 4) / 2, (Curses.cols - prompt_message.length - 10) / 2
  )
  dialog.box('|', '-', '+')
  dialog.setpos(1, 2)
  dialog.addstr(prompt_message)
  dialog.setpos(1, prompt_message.length + 2)

  Curses.echo # 入力を表示するモード
  Curses.curs_set(1) # カーソルの可視化

  str = dialog.getstr # 文字列入力待ち

  Curses.noecho # 入力を非表示に
  Curses.curs_set(0) # カーソルの非表示

  dialog.close
  str.to_i
end

def show_done_dialog(mwin, calculated_pi)
  doneMessage = "DONE!!! PI is #{format('%#.010g', calculated_pi)}!!"

  dialog = mwin.subwin(5, doneMessage.length + 6, (Curses.lines / 2) - 2, (Curses.cols / 2) - ((doneMessage.length + 6) / 2))
  dialog.box('#', '#', '#')
  dialog.setpos(2, 3)
  dialog.attron(Curses::A_BOLD)
  dialog.attron(Curses::A_UNDERLINE)
  dialog.addstr(doneMessage)
  dialog.attroff(Curses::A_UNDERLINE)
  dialog.attroff(Curses::A_BOLD)
  dialog.refresh
end

begin
  try_times = get_try_times

  calculated_pi = 0.0
  inside_circle_counter = 0

  header.myInit
  footer.myInit
  graph.myInit

  try_times.times do |index|
    header.show_str("MC method #{(100 * index / try_times.to_f).to_i}%")
    header.refresh

    rand_x = rand
    rand_y = rand
    point = { x: rand_x * graph_size[:x],
              y: rand_y * graph_size[:y] }
    distance = ((rand_x**2) + (rand_y**2))**0.5
    inside_circle_counter += 1 if 1 >= distance
    graph.addPoint(point[:x], point[:y], distance)
    graph.refresh

    calculated_pi = ((inside_circle_counter / (index + 1).to_f) * 4.0)
    footer.show_str("PI is #{format('%#.010g', calculated_pi)}")
    footer.refresh

    Curses.refresh
  end
  show_done_dialog(mwin, calculated_pi)
  Curses.getch
ensure
  Curses.close_screen
end
