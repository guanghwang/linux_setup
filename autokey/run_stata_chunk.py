# Enter script code
import time
shortdelay = 0.2

current = window.get_active_title()
window.activate("Stata/MP 14.1")
cmd = clipboard.get_selection()

time.sleep(shortdelay)
keyboard.send_keys(cmd)
keyboard.send_keys("<enter>")

time.sleep(shortdelay)
window.activate(current)
keyboard.send_keys("<escape>")