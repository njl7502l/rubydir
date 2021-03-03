require 'curses'

# Curses.resizeterm(56, 100)
mwin = Curses.init_screen
mwin.box('|', '-', '+')

begin
  try_times = 10_000

  score = 0
  try_times.times do |index|
    # init #########################
    headerString = "MC method #{(100 * index / try_times.to_f).to_i}%"

    graphAriaLength = { y: Curses.lines - 6, x: Curses.cols }
    graphAriaOrigin = { y: 3, x: 0 }
    graphAriaCenter = { y: graphAriaLength[:y] / 2 + graphAriaOrigin[:y],
                        x: graphAriaLength[:x] / 2 + graphAriaOrigin[:x] }

    Curses.setpos(0, 0)
    Curses.addstr("#{Curses.lines}, #{Curses.cols}")
    graphLength = {
      x: if (graphAriaLength[:y] * 2) > graphAriaLength[:x]
           graphAriaLength[:x]
         else
           graphAriaLength[:y] * 2
         end
    }
    graphLength.merge!(y: graphLength[:x] / 2)

    graphOrigin = {
      x: graphAriaCenter[:x] - (graphLength[:x] / 2),
      y: graphAriaCenter[:y] - (graphLength[:y] / 2)
    }
    Curses.start_color
    Curses.init_pair(1, Curses::COLOR_RED, Curses::COLOR_BLACK)
    Curses.init_pair(2, Curses::COLOR_YELLOW, Curses::COLOR_BLACK)

    # Curses.attrset(Curses.color_pair(16))
    # calculation #########################
    rand_x = rand
    rand_y = rand
    point = { x: rand_x * graphLength[:x],
              y: rand_y * graphLength[:y] }
    distance = (((0.5 - rand_x)**2) + ((0.5 - rand_y)**2))**0.5

    score += 1 if 0.5 > distance
    sws2 = "PI is #{format('%#.010g', ((score / index.to_f) * 4.0))}"

    graph = mwin.subwin(graphLength[:y], graphLength[:x], graphOrigin[:y], graphOrigin[:x])
    graph.box('|', '-', '+')
    graph.setpos(graphLength[:y] / 2, graphLength[:x] / 2) # Curses.cols / 2)
    graph.attron(Curses.color_pair(1))
    graph.addstr('+')
    graph.attroff(Curses.color_pair(1))
    graph.setpos(point[:y], point[:x])

    graph.attron(Curses.color_pair(2)) if 0.5 > distance
    graph.addstr('.')
    graph.attroff(Curses.color_pair(2)) if 0.5 > distance
    # end
    graph.refresh

    header = mwin.subwin(3, Curses.cols, 0, 0)
    header.box('|', '-', '+')
    header.setpos(1, Curses.cols / 2 - (headerString.length / 2))
    header.addstr(headerString)
    header.refresh

    footer = mwin.subwin(3, Curses.cols, Curses.lines - 3, 0)
    footer.box('|', '-', '+')
    footer.setpos(1, Curses.cols / 2 - (sws2.length / 2))
    footer.addstr(sws2)
    footer.refresh

    Curses.refresh
  end
  doneMessage = "DONE!!! PI is #{format('%#.05g', ((score / try_times.to_f) * 4.0))}!!"
  dialog = mwin.subwin(5, doneMessage.length + 6, (Curses.lines / 2) - 2, (Curses.cols / 2) - ((doneMessage.length + 6) / 2))
  dialog.box('#', '#', '+')
  dialog.setpos(2, 3)
  dialog.attron(Curses::A_UNDERLINE)
  dialog.addstr(doneMessage)
  dialog.attroff(Curses::A_UNDERLINE)
  dialog.refresh
  Curses.getch
ensure
  Curses.close_screen
end
