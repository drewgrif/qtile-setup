# Copyright (c) 2025 JustAGuyLinux

from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen, ScratchPad, DropDown
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
import os
import subprocess

from libqtile import hook
from colors import *

def notify_layout():
    """Show current layout in notification"""
    def _notify_layout(qtile):
        layout_name = qtile.current_group.layout.name
        layout_map = {
            "monadtall": "Monad Tall",
            "columns": "Columns", 
            "bsp": "BSP",
            "treetab": "Tree Tab",
            "matrix": "Matrix",
            "plasma": "Plasma",
            "floating": "Floating",
            "spiral": "Spiral",
            "ratiotile": "Ratio Tile",
            "max": "Maximized",
            "monadwide": "Monad Wide",
            "tile": "Tile",
            "verticaltile": "Vertical Tile",
            "stack": "Stack",
            "zoomy": "Zoomy"
        }
        display_name = layout_map.get(layout_name, layout_name.title())
        subprocess.run(["notify-send", "Layout", display_name, "-t", "1500", "-u", "low"])
    return _notify_layout

def notify_restart():
    """Show restart notification"""
    def _notify_restart(qtile):
        subprocess.run(["notify-send", "Qtile", "Restarting...", "-t", "2000", "-u", "normal"])
    return _notify_restart

def toggle_float_center():
    """Toggle floating and center at 75% size"""
    def _toggle_float_center(qtile):
        window = qtile.current_window
        if window:
            was_floating = window.floating
            window.toggle_floating()
            if not was_floating and window.floating:
                # Only resize/center when going from tiled to floating
                screen = qtile.current_screen
                width = int(screen.width * 0.70)
                height = int(screen.height * 0.60)
                window.set_size_floating(width, height)
                window.center()
    return _toggle_float_center

def resize_left():
    """Resize window left - intuitive based on focus"""
    def _resize_left(qtile):
        layout = qtile.current_layout.name
        group = qtile.current_group
        
        # For BSP/Columns layouts with directional resize
        if layout in ["bsp", "columns"]:
            qtile.current_layout.cmd_grow_left()
        # For MonadTall/Tile - check if we're in main or stack area
        elif layout in ["monadtall", "monadwide", "tile", "ratiotile"]:
            # Get current window index
            current_idx = group.windows.index(qtile.current_window)
            # First window is usually main, so reverse the behavior
            if current_idx == 0:
                qtile.current_layout.cmd_shrink()
            else:
                qtile.current_layout.cmd_grow()
        else:
            # Default behavior for other layouts
            qtile.current_layout.cmd_shrink()
    return _resize_left

def resize_right():
    """Resize window right - intuitive based on focus"""
    def _resize_right(qtile):
        layout = qtile.current_layout.name
        group = qtile.current_group
        
        # For BSP/Columns layouts with directional resize
        if layout in ["bsp", "columns"]:
            qtile.current_layout.cmd_grow_right()
        # For MonadTall/Tile - check if we're in main or stack area
        elif layout in ["monadtall", "monadwide", "tile", "ratiotile"]:
            # Get current window index
            current_idx = group.windows.index(qtile.current_window)
            # First window is usually main, so reverse the behavior
            if current_idx == 0:
                qtile.current_layout.cmd_grow()
            else:
                qtile.current_layout.cmd_shrink()
        else:
            # Default behavior for other layouts
            qtile.current_layout.cmd_grow()
    return _resize_right

def focus_left():
    """Focus window to the left, or cycle if floating"""
    def _focus_left(qtile):
        if qtile.current_layout.name == "floating" or qtile.current_window.floating:
            qtile.current_group.cmd_prev_window()
        else:
            qtile.current_layout.cmd_left()
    return _focus_left

def focus_right():
    """Focus window to the right, or cycle if floating"""
    def _focus_right(qtile):
        if qtile.current_layout.name == "floating" or qtile.current_window.floating:
            qtile.current_group.cmd_next_window()
        else:
            qtile.current_layout.cmd_right()
    return _focus_right

@hook.subscribe.startup_once
def autostart():
   home = os.path.expanduser('~/.config/qtile/scripts/autostart.sh')
   subprocess.run([home])



mod = "mod4"
terminal = "wezterm"
browser = "firefox"

colors, backgroundColor, foregroundColor, workspaceColor, foregroundColorTwo = github_dark()

keys = [

# Add dedicated sxhkdrc to autostart.sh script

# CLOSE WINDOW, RELOAD AND QUIT QTILE
    Key([mod], "q", lazy.window.kill(), desc="Close focused window"),
# Qtile System Actions
    Key([mod, "shift"], "r", lazy.function(notify_restart()), lazy.restart(), desc="Restart Qtile"),
    Key([mod, "shift"], "q", lazy.shutdown(), desc="Exit Qtile"),
   #  Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),

# CHANGE FOCUS USING VIM OR DIRECTIONAL KEYS
    Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "Left", lazy.function(focus_left()), desc="Move focus left"),
    Key([mod], "Right", lazy.function(focus_right()), desc="Move focus right"),
    
    # CYCLE THROUGH ALL WINDOWS (INCLUDING FLOATING)
    Key([mod], "j", lazy.group.next_window(), desc="Focus next window"),
    Key([mod], "k", lazy.group.prev_window(), desc="Focus previous window"),
    Key(["mod1"], "Tab", lazy.group.next_window(), desc="Alt-Tab window switching"),
    Key(["mod1", "shift"], "Tab", lazy.group.prev_window(), desc="Alt-Shift-Tab window switching"),


# MOVE WINDOWS UP OR DOWN,LEFT OR RIGHT USING VIM KEYS
    Key([mod, "shift"], "k", 
        lazy.layout.shuffle_up(),
        lazy.layout.shuffle_left(),
        desc="Move window up/left"),
    Key([mod, "shift"], "j", 
        lazy.layout.shuffle_down(),
        lazy.layout.shuffle_right(),
        desc="Move window down/right"),

# MOVE WINDOWS UP OR DOWN,LEFT OR RIGHT USING DIRECTIONAL KEYS
    Key([mod, "shift"], "Left", 
        lazy.layout.shuffle_left(),
        lazy.layout.swap_left(),
        desc="Move window left"),
    Key([mod, "shift"], "Right", 
        lazy.layout.shuffle_right(),
        lazy.layout.swap_right(),
        desc="Move window right"),
    Key([mod, "shift"], "Up", 
        lazy.layout.shuffle_up(),
        desc="Move window up"),
    Key([mod, "shift"], "Down", 
        lazy.layout.shuffle_down(),
        desc="Move window down"),

# RESIZE UP, DOWN, LEFT, RIGHT USING DIRECTIONAL KEYS
    Key([mod, "control"], "Right",
        lazy.function(resize_right()),
        desc="Resize window right"
        ),
    Key([mod, "control"], "Left",
        lazy.function(resize_left()),
        desc="Resize window left"
        ),
    Key([mod, "control"], "Up",
        lazy.layout.grow_up(),
        lazy.layout.grow(),
        lazy.layout.decrease_nmaster(),
        desc="Grow window up"
        ),
    Key([mod, "control"], "Down",
        lazy.layout.grow_down(),
        lazy.layout.shrink(),
        lazy.layout.increase_nmaster(),
        desc="Grow window down"
        ),

# QTILE LAYOUT KEYS
    Key([mod], "Tab", lazy.next_layout(), lazy.function(notify_layout()), desc="Toggle between layouts"),

# TOGGLE FLOATING LAYOUT
    Key([mod, "shift"], "space", 
        lazy.function(toggle_float_center()),
        desc="Toggle floating and center at 75%"),
    Key([mod, "shift"], "z", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "t", lazy.layout.toggle_split(), desc="Toggle split direction in BSP"),

# APPLICATION LAUNCHERS
    Key([mod], "b", lazy.spawn(browser), desc="Launch browser"),
    Key([mod, "shift"], "b", lazy.spawn("firefox-esr -private-window"), desc="Launch Firefox (Private)"),
    Key([mod], "Return", lazy.spawn("wezterm"), desc="Launch terminal"),
    Key([mod], "space", lazy.spawn("rofi -show drun -modi drun -line-padding 4 -hide-scrollbar -show-icons -theme ~/.config/qtile/rofi/config.rasi"), desc="Launch Rofi"),
    Key([mod], "h", lazy.spawn(f"python3 {os.path.expanduser('~/.config/qtile/scripts/help')}"), desc="Show keybindings"),
    Key([mod], "f", lazy.spawn("thunar"), desc="Launch file manager"),
    Key([mod], "e", lazy.spawn("geany"), desc="Launch text editor"),
    Key([mod], "g", lazy.spawn("gimp"), desc="Launch GIMP"),
    Key([mod], "d", lazy.spawn("Discord"), desc="Launch Discord"),
    Key([mod], "o", lazy.spawn("obs"), desc="Launch OBS"),
    Key([mod], "x", lazy.spawn(os.path.expanduser("~/.config/qtile/scripts/power")), desc="Power menu"),

# VOLUME CONTROLS
    Key([mod], "Insert", lazy.spawn(os.path.expanduser("~/.config/qtile/scripts/changevolume up")), desc="Volume up"),
    Key([mod], "Delete", lazy.spawn(os.path.expanduser("~/.config/qtile/scripts/changevolume down")), desc="Volume down"),
    Key([mod], "m", lazy.spawn(os.path.expanduser("~/.config/qtile/scripts/changevolume mute")), desc="Mute/Unmute"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn(os.path.expanduser("~/.config/qtile/scripts/changevolume up")), desc="Volume up"),
    Key([], "XF86AudioLowerVolume", lazy.spawn(os.path.expanduser("~/.config/qtile/scripts/changevolume down")), desc="Volume down"),
    Key([], "XF86AudioMute", lazy.spawn(os.path.expanduser("~/.config/qtile/scripts/changevolume mute")), desc="Mute/Unmute"),

# BRIGHTNESS CONTROLS
    Key([], "XF86MonBrightnessUp", lazy.spawn("xbacklight +10"), desc="Brightness up"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("xbacklight -10"), desc="Brightness down"),

# SCREENSHOTS
    Key([mod], "Print", lazy.spawn("flameshot gui --path " + os.path.expanduser("~/Screenshots/")), desc="Screenshot (region select)"),
    Key([], "Print", lazy.spawn("flameshot full --path " + os.path.expanduser("~/Screenshots/")), desc="Screenshot (full screen)"),
    Key([mod, "shift"], "s", lazy.spawn("flameshot gui --path " + os.path.expanduser("~/Screenshots/")), desc="Screenshot (region select alt)"),
    ]

# Scratchpad keybindings
keys.extend([
    Key([mod, "shift"], "Return", lazy.group['scratchpad'].dropdown_toggle('terminal')),
    Key([mod], "v", lazy.group['scratchpad'].dropdown_toggle('volume'), desc="Toggle volume scratchpad"),
])

# end of keys

#groups = [Group(i) for i in ["", "", "", "", "阮", "", "", "", ""]]
# groups = [Group(i) for i in ["1", "2", "3", "4", "5", "6", "7", "8", "9"]]
groups = [
	Group('1', label="1", layout="bsp"),
	Group('2', label="2", matches=[Match(wm_class='GitHub Desktop')], layout="bsp"),
	Group('3', label="3", layout="bsp"),	
	Group('4', label="4", layout="bsp"),
	Group('5', label="5", layout="bsp"),
	Group('6', label="6", layout="bsp"),
	Group('7', label="7", matches=[Match(wm_class='gimp')], layout="max"),
	Group('8', label="8", matches=[Match(wm_class='discord')], layout="max"),
	Group('9', label="9", matches=[Match(wm_class='obs')], layout="columns"),
	Group('0', label="10", layout="bsp"),
	Group('minus', label="11", layout="bsp"),
	Group('equal', label="12", layout="bsp"),
]

# Define scratchpads
groups.append(ScratchPad("scratchpad", [
    DropDown("terminal", "st", width=0.6, height=0.6, x=0.2, y=0.02, opacity=0.95),
    DropDown("volume", "st -c volume -e pulsemixer", width=0.5, height=0.5, x=0.25, y=0.02, opacity=0.95),
]))



#groups = [Group(i) for i in ["www", "dev", "dir", "txt", "vid", "mus", "gfx", "dis", "obs"]]
# group_hotkeys = "123456789"

for i in groups:
    if i.name != "scratchpad":  # Skip scratchpad groups
        keys.extend(
            [
                # mod1 + letter of group = switch to group
                Key(
                    [mod],
                    i.name,
                    lazy.group[i.name].toscreen(),
                    desc="Switch to group {}".format(i.name),
                ),
                # mod1 + shift + letter of group = switch to & move focused window to group
                Key(
                    [mod, "shift"],
                    i.name,
                    lazy.window.togroup(i.name, switch_group=True),
                    desc="Switch to & move focused window to group {}".format(i.name),
                ),
                # Or, use below if you prefer not to switch to that group.
                # # mod1 + shift + letter of group = move focused window to group
                # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
                #     desc="move focused window to group {}".format(i.name)),
            ]
        )

# Define layouts and layout themes
layout_theme = {
        "margin":10,
        "border_width": 4,
        "border_focus": colors[3],
        "border_normal": colors[1]
    }

# Layout preference by monitor type:
# BSP - Traditional monitors (16:9, 4:3)
# Columns - Ultrawide monitors (21:9, 32:9)
layouts = [
    layout.Bsp(**layout_theme),
    layout.Columns(**layout_theme, num_columns=3),
    layout.MonadTall(**layout_theme),
    layout.Max(**layout_theme),
    layout.Floating(**layout_theme),
    layout.Zoomy(**layout_theme),
]

# Updated widget defaults to match Polybar styling
widget_defaults = dict(
    font='Roboto Mono Nerd Font',  # Match Polybar font
    background=backgroundColor,
    foreground=foregroundColor,
    fontsize=16,  # Increased font size
    padding=4,
)
extension_defaults = widget_defaults.copy()

# Custom separator to match Polybar
def create_separator():
    return widget.TextBox(
        text="|",
        foreground=foregroundColorTwo,  # disabled color
        padding=8,
        fontsize=14
    )

# Custom widget for keyboard lock indicator
# Using built-in CapsNumLockIndicator widget instead of custom implementation


screens = [
    Screen(
        top=bar.Bar(
            [
                # Layout indicator
                widget.Spacer(length=8),
                widget.CurrentLayoutIcon(
                    custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons/layouts")],
                    foreground=colors[6][0],
                    scale=0.6,
                    padding=4
                ),
                create_separator(),
                
                # Left modules - System info
                widget.TextBox(
                    text="󰍛",
                    foreground=colors[6][0],
                    padding=2
                ),
                widget.Memory(
                    format='{MemPercent:2.0f}%',
                    foreground=foregroundColor,
                    padding=2
                ),
                create_separator(),
                widget.TextBox(
                    text="󰻠",
                    foreground=colors[6][0],
                    padding=2
                ),
                widget.CPU(
                    format="{load_percent:2.0f}%",
                    foreground=foregroundColor,
                    padding=2
                ),
                create_separator(),
                widget.TextBox(
                    text="󰋊",
                    foreground=colors[6][0],
                    padding=6
                ),
                widget.DF(
                    visible_on_warn=False,
                    format='{r:.0f}%',
                    partition='/',
                    foreground=foregroundColor,
                    padding=2
                ),
                
                # Center - Workspaces
                widget.Spacer(),
                widget.GroupBox(
                    disable_drag=True,
                    use_mouse_wheel=False,
                    active=foregroundColor,
                    inactive=foregroundColorTwo,
                    highlight_method='line',
                    highlight_color=[backgroundColor, backgroundColor],
                    this_current_screen_border=colors[6][0],
                    this_screen_border=colors[1][0],
                    other_current_screen_border=colors[1][0],
                    other_screen_border=backgroundColor,
                    urgent_alert_method='text',
                    urgent_text=colors[10][0],
                    rounded=False,
                    margin_x=0,
                    margin_y=2,
                    padding_x=8,
                    padding_y=4,
                    borderwidth=3,
                    hide_unused=True,
                ),
                widget.Spacer(),
                
                # Right modules
                widget.GenPollText(
                    func=lambda: " CAPS " if "Caps Lock:   on" in subprocess.run(['xset', 'q'], capture_output=True, text=True).stdout else "",
                    update_interval=0.5,
                    padding=4,
                    foreground=colors[10][0],
                ),
                widget.Systray(
                    padding=4,
                ),
                create_separator(),
                widget.TextBox(
                    text="󰕾",
                    foreground=colors[6][0],
                    padding=6,
                    mouse_callbacks={'Button1': lazy.spawn("pavucontrol")},
                ),
                widget.Volume(
                    fmt="{}",
                    mute_command="pamixer -t",
                    volume_up_command="pamixer -i 2",
                    volume_down_command="pamixer -d 2",
                    get_volume_command="pamixer --get-volume-human",
                    check_mute_command="pamixer --get-mute",
                    check_mute_string="true",
                    foreground=foregroundColor,
                    padding=2
                ),
                create_separator(),
                widget.Clock(
                    format='%a, %b %-d',
                    foreground=foregroundColorTwo,
                    padding=4
                ),
                create_separator(),
                widget.Clock(
                    format='%-l:%M %p',
                    foreground=foregroundColor,
                    padding=4
                ),
                widget.Spacer(length=8),
            ],
            24,  # Match Polybar's 24pt height
            background=backgroundColor,
            margin=[0, 0, 0, 0],  # Remove margins for full-width bar
            # border_width=[0, 0, 0, 0],  # No borders to match Polybar
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = False
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
border_width=4,
border_focus=colors[3],
border_normal=colors[1],
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="qimgv"),  # q image viewer
        Match(wm_class="lxappearance"),  # lxappearance
        Match(wm_class="pavucontrol"),  # pavucontrol
        Match(wm_class="Galculator"),  # calculator
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = None

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"
