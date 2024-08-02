#!/usr/bin/env nu

# Send some notifications with dunst to see how they look
def main [] {
    [0 2 1] | each {|i|
        do -c {
            ^dunstify --timeout 0 --urgency $i --appname "Test app" "Summary" "Notification content"
        }
    }

    do -c {
        (
            ^dunstify --timeout 0 --urgency 1 --appname "Test app"
                "Now with icons" "This one has an icon!!!"
                --icon audio-volume-medium-symbolic
        )
    }
}
